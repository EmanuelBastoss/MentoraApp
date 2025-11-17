import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mentoraapp/componentes/my_button.dart';
import 'package:mentoraapp/componentes/my_textfield.dart';
import 'package:mentoraapp/services/auth/auth_service.dart';
import 'package:mentoraapp/services/storage/storage_service.dart';
import 'package:mentoraapp/utils/image_helper.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cursoController = TextEditingController();
  final TextEditingController _periodoController = TextEditingController();
  final TextEditingController _duvidaBioController = TextEditingController();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  String? _profileImageUrl;
  File? _selectedImage;

  final List<String> _cursos = [
    'Ciência da Computação',
    'Engenharia de Software',
    'Sistemas de Informação',
    'Engenharia de Computação',
    'Análise e Desenvolvimento de Sistemas',
    'Outro',
  ];
  String? _cursoSelecionado;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;

    final userDoc = await _firestore
        .collection('Users')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data()!;
      setState(() {
        _nomeController.text = userData['nome'] ?? '';
        _cursoSelecionado = userData['curso'];
        _periodoController.text = userData['periodo']?.toString() ?? '';
        _duvidaBioController.text = userData['duvidaBio'] ?? '';
        _profileImageUrl = userData['profileImageUrl'];
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, informe seu nome")),
      );
      return;
    }

    if (_cursoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecione um curso")),
      );
      return;
    }

    if (_periodoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, informe o período")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) return;

      String? newImageUrl = _profileImageUrl;

      // Se uma nova imagem foi selecionada, fazer upload
      if (_selectedImage != null) {
        try {
          // Fazer upload da nova imagem primeiro
          newImageUrl = await _storageService.uploadProfilePicture(
            _selectedImage!,
          );

          // Depois que o upload foi bem-sucedido, tentar deletar a imagem antiga
          if (_profileImageUrl != null &&
              _profileImageUrl!.isNotEmpty &&
              _profileImageUrl != newImageUrl) {
            // Não bloquear se falhar ao deletar
            _storageService.deleteProfilePicture(_profileImageUrl).catchError((
              e,
            ) {
              print('Aviso: Não foi possível deletar imagem antiga: $e');
            });
          }
        } catch (e) {
          if (mounted) {
            final errorMessage = e.toString().replaceAll('Exception: ', '');
            
            // Mostrar diálogo com instruções se for erro de configuração
            if (errorMessage.contains('Storage não configurado') || 
                errorMessage.contains('Sem permissão') ||
                errorMessage.contains('404')) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Configuração Necessária'),
                  content: SingleChildScrollView(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
            
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
      }

      await _firestore.collection('Users').doc(currentUser.uid).update({
        'nome': _nomeController.text.trim(),
        'curso': _cursoSelecionado,
        'periodo': int.parse(_periodoController.text),
        'duvidaBio': _duvidaBioController.text.trim(),
        'profileImageUrl': newImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil atualizado com sucesso!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao atualizar perfil: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      // Mostrar opções: câmera ou galeria
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Galeria"),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Câmera"),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70, // Qualidade reduzida para garantir que fique abaixo de 500KB
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao selecionar imagem: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foto de perfil
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : ImageHelper.getImageProvider(_profileImageUrl),
                    child:
                        _selectedImage == null &&
                            (_profileImageUrl == null ||
                                _profileImageUrl!.isEmpty)
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        color: Theme.of(context).colorScheme.onPrimary,
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            MyTextField(
              hintText: "Nome completo",
              obscureText: false,
              controller: _nomeController,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              child: DropdownButton<String>(
                hint: const Text("Selecione seu curso"),
                value: _cursoSelecionado,
                isExpanded: true,
                underline: const SizedBox(),
                items: _cursos.map((String curso) {
                  return DropdownMenuItem<String>(
                    value: curso,
                    child: Text(curso),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _cursoSelecionado = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            MyTextField(
              hintText: "Período (ex: 1, 2, 3...)",
              obscureText: false,
              controller: _periodoController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            MyTextField(
              hintText: "Dúvida principal ou Bio",
              obscureText: false,
              controller: _duvidaBioController,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            MyButton(
              text: _isLoading ? "Salvando..." : "Salvar Alterações",
              onTap: _isLoading ? null : _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cursoController.dispose();
    _periodoController.dispose();
    _duvidaBioController.dispose();
    super.dispose();
  }
}
