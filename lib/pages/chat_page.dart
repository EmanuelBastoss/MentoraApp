import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentoraapp/services/auth/auth_service.dart';
import 'package:mentoraapp/services/chat/chat_service.dart';
import 'package:mentoraapp/utils/image_helper.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  const ChatPage({super.key, required this.receiverEmail});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        await _chatService.sendMessage(
          widget.receiverEmail,
          _messageController.text,
          currentUser.email!,
        );
        _messageController.clear();
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Marcar mensagens como lidas quando a página é aberta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        _chatService.markMessagesAsRead(
          currentUser.email!,
          widget.receiverEmail,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.getCurrentUser();
    final senderEmail = currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('Users')
              .where('email', isEqualTo: widget.receiverEmail)
              .limit(1)
              .snapshots(),
          builder: (context, receiverSnapshot) {
            if (!receiverSnapshot.hasData ||
                receiverSnapshot.data!.docs.isEmpty) {
              return Text(widget.receiverEmail);
            }
            final receiverData =
                receiverSnapshot.data!.docs.first.data()
                    as Map<String, dynamic>;
            final receiverName = receiverData['nome'] ?? widget.receiverEmail;
            final receiverImageUrl = receiverData['profileImageUrl'];
            return Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  backgroundImage: ImageHelper.getImageProvider(
                    receiverImageUrl,
                  ),
                  child: receiverImageUrl == null || receiverImageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(receiverName)),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(senderEmail)),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList(String senderEmail) {
    return FutureBuilder<Stream<QuerySnapshot>>(
      future: _chatService.getMessages(senderEmail, widget.receiverEmail),
      builder: (context, streamSnapshot) {
        if (!streamSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return StreamBuilder<QuerySnapshot>(
          stream: streamSnapshot.data,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Erro ao carregar mensagens"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("Nenhuma mensagem ainda. Comece a conversar!"),
              );
            }

            // Scroll automático para a última mensagem
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            return ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final isCurrentUser = data['senderEmail'] == senderEmail;
                final senderEmailFromData =
                    data['senderEmail'] as String? ?? '';

                return _buildMessageItem(
                  data,
                  isCurrentUser,
                  senderEmailFromData,
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageItem(
    Map<String, dynamic> data,
    bool isCurrentUser,
    String senderEmail,
  ) {
    Color backgroundColor = isCurrentUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    // Buscar foto de perfil do remetente
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Users')
          .where('email', isEqualTo: senderEmail)
          .limit(1)
          .snapshots(),
      builder: (context, userSnapshot) {
        String? profileImageUrl;
        String? userName;

        if (userSnapshot.hasData && userSnapshot.data!.docs.isNotEmpty) {
          final userData =
              userSnapshot.data!.docs.first.data() as Map<String, dynamic>;
          profileImageUrl = userData['profileImageUrl'];
          userName = userData['nome'];
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: isCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isCurrentUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  backgroundImage: ImageHelper.getImageProvider(
                    profileImageUrl,
                  ),
                  child: profileImageUrl == null || profileImageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isCurrentUser ? 12 : 4),
                      bottomRight: Radius.circular(isCurrentUser ? 4 : 12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!isCurrentUser && userName != null) ...[
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondary.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        data['message'] ?? '',
                        style: TextStyle(
                          color: isCurrentUser
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (data['timestamp'] != null)
                        Text(
                          _formatTimestamp(data['timestamp']),
                          style: TextStyle(
                            fontSize: 10,
                            color: isCurrentUser
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onPrimary.withOpacity(0.7)
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSecondary.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isCurrentUser)
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('Users')
                      .doc(_authService.getCurrentUser()?.uid ?? '')
                      .snapshots(),
                  builder: (context, currentUserSnapshot) {
                    String? currentUserImageUrl;
                    if (currentUserSnapshot.hasData) {
                      final currentUserData =
                          currentUserSnapshot.data!.data()
                              as Map<String, dynamic>?;
                      currentUserImageUrl = currentUserData?['profileImageUrl'];
                    }
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          backgroundImage: ImageHelper.getImageProvider(
                            currentUserImageUrl,
                          ),
                          child:
                              currentUserImageUrl == null ||
                                  currentUserImageUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                )
                              : null,
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Digite uma mensagem...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Ontem';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
    return '';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
