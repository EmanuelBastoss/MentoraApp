import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentoraapp/pages/edit_profile_page.dart';
import 'package:mentoraapp/services/auth/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final currentUser = _authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(title: const Text("Configurações")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection("Users")
            .doc(currentUser?.uid ?? '')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final userType = userData?['tipoUsuario'] ?? 'aluno';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Editar Perfil"),
                  subtitle: Text("Altere seus dados pessoais"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text("Informações do Perfil"),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text("Nome"),
                      subtitle: Text(userData?['nome'] ?? 'Não informado'),
                    ),
                    ListTile(
                      title: const Text("Email"),
                      subtitle: Text(userData?['email'] ?? 'Não informado'),
                    ),
                    ListTile(
                      title: const Text("Curso"),
                      subtitle: Text(userData?['curso'] ?? 'Não informado'),
                    ),
                    ListTile(
                      title: const Text("Período"),
                      subtitle: Text(
                        userData?['periodo'] != null
                            ? "${userData!['periodo']}º período"
                            : 'Não informado',
                      ),
                    ),
                    ListTile(
                      title: const Text("Tipo de Perfil"),
                      subtitle: Text(userType == 'aluno' ? 'Aluno' : 'Mentor'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
