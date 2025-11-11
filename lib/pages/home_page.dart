import 'package:flutter/material.dart';
import 'package:mentoraapp/componentes/user_tile.dart';
import 'package:mentoraapp/pages/chat_page.dart';
import 'package:mentoraapp/services/auth/auth_service.dart';
import 'package:mentoraapp/componentes/my_drawer.dart';
import 'package:mentoraapp/services/chat/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("home")),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading");
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }
}

Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
  if (userData["email"] != _authService.getCurrentUser()) {
    return UserTile(
      text: userData["email"],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(receiverEmail: userData["email"]),
          ),
        );
      },
    );
  }
}
