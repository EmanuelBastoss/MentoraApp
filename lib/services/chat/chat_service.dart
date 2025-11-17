import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // Obter ID do chat entre dois usuários
  Future<String> getChatRoomId(String userEmail1, String userEmail2) async {
    // Normalizar emails para evitar problemas com caracteres especiais
    final email1 = userEmail1.toLowerCase().trim();
    final email2 = userEmail2.toLowerCase().trim();

    if (email1.compareTo(email2) < 0) {
      return "${email1}_${email2}";
    } else {
      return "${email2}_${email1}";
    }
  }

  // Obter mensagens do chat
  Future<Stream<QuerySnapshot>> getMessages(
    String userEmail1,
    String userEmail2,
  ) async {
    final String chatRoomId = await getChatRoomId(userEmail1, userEmail2);
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Enviar mensagem
  Future<void> sendMessage(
    String receiverEmail,
    String message,
    String senderEmail,
  ) async {
    final String chatRoomId = await getChatRoomId(senderEmail, receiverEmail);
    final String currentUserEmail = senderEmail;

    // Criar documento na coleção de mensagens
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
          'senderEmail': currentUserEmail,
          'receiverEmail': receiverEmail,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });

    // Atualizar contador de mensagens não lidas para o receptor
    await _firestore
        .collection('Users')
        .where('email', isEqualTo: receiverEmail)
        .get()
        .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            final receiverDoc = querySnapshot.docs.first;
            final unreadCounts = receiverDoc.data()['unreadCounts'] ?? {};
            unreadCounts[senderEmail] = (unreadCounts[senderEmail] ?? 0) + 1;
            receiverDoc.reference.update({'unreadCounts': unreadCounts});
          }
        });
  }

  // Marcar mensagens como lidas
  Future<void> markMessagesAsRead(
    String currentUserEmail,
    String otherUserEmail,
  ) async {
    final String chatRoomId = await getChatRoomId(
      currentUserEmail,
      otherUserEmail,
    );

    // Marcar todas as mensagens não lidas como lidas
    final messages = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('read', isEqualTo: false)
        .where('receiverEmail', isEqualTo: currentUserEmail)
        .get();

    if (messages.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    }

    // Resetar contador de mensagens não lidas
    final currentUser = await _firestore
        .collection('Users')
        .where('email', isEqualTo: currentUserEmail)
        .get();

    if (currentUser.docs.isNotEmpty) {
      final userDoc = currentUser.docs.first;
      final unreadCounts = userDoc.data()['unreadCounts'] ?? {};
      unreadCounts[otherUserEmail] = 0;
      await userDoc.reference.update({'unreadCounts': unreadCounts});
    }
  }

  // Obter contagem de mensagens não lidas
  Stream<int> getUnreadCount(String currentUserUid, String otherUserEmail) {
    return _firestore.collection('Users').doc(currentUserUid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) return 0;
      final userData = snapshot.data() ?? {};
      final unreadCounts = userData['unreadCounts'] ?? {};
      return unreadCounts[otherUserEmail] ?? 0;
    });
  }
}
