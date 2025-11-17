import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentoraapp/componentes/user_tile.dart';
import 'package:mentoraapp/pages/chat_page.dart';
import 'package:mentoraapp/pages/create_post_page.dart';
import 'package:mentoraapp/services/auth/auth_service.dart';
import 'package:mentoraapp/componentes/my_drawer.dart';
import 'package:mentoraapp/services/chat/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection("Users")
              .doc(_authService.getCurrentUser()?.uid ?? '')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("MentoraApp");
            }
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final userType = userData?['tipoUsuario'] ?? 'aluno';
            return Text(userType == 'mentor' ? 'Alunos' : 'Mentores');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostPage()),
              );
            },
            tooltip: 'Criar post',
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar usuários"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null || userData["email"] == currentUser.email) {
      return const SizedBox.shrink();
    }

    // Obter tipo do usuário atual
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection("Users").doc(currentUser.uid).snapshots(),
      builder: (context, currentUserSnapshot) {
        if (!currentUserSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final currentUserData =
            currentUserSnapshot.data!.data() as Map<String, dynamic>?;
        final currentUserType = currentUserData?['tipoUsuario'] ?? 'aluno';

        // Filtrar usuários baseado no tipo
        final userType = userData['tipoUsuario'] ?? 'aluno';

        // Mentores veem apenas alunos, alunos veem apenas mentores
        if (currentUserType == 'mentor' && userType != 'aluno') {
          return const SizedBox.shrink();
        }
        if (currentUserType == 'aluno' && userType != 'mentor') {
          return const SizedBox.shrink();
        }

        // Verificar se são do mesmo curso (opcional - pode remover se quiser ver todos)
        // Descomente as linhas abaixo se quiser filtrar por curso
        // final currentUserCurso = currentUserData?['curso'];
        // final userCurso = userData['curso'];
        // if (currentUserCurso != null && userCurso != currentUserCurso) {
        //   return const SizedBox.shrink();
        // }

        final otherUserEmail = userData["email"] ?? '';

        return StreamBuilder<int>(
          stream: _chatService.getUnreadCount(currentUser.uid, otherUserEmail),
          builder: (context, unreadSnapshot) {
            final unreadCount = unreadSnapshot.data ?? 0;
            return UserTile(
              text: userData["nome"] ?? userData["email"] ?? "Usuário",
              subtitle: userData['duvidaBio'] ?? '',
              curso: userData['curso'],
              periodo: userData['periodo'],
              unreadCount: unreadCount > 0 ? unreadCount : null,
              profileImageUrl: userData['profileImageUrl'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatPage(receiverEmail: userData["email"]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
