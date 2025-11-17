import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload de foto de perfil usando Base64 (armazenado no Firestore)
  // Alternativa para quem não pode usar Firebase Storage
  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      // Verificar se o arquivo existe
      if (!await imageFile.exists()) {
        throw Exception('Arquivo de imagem não encontrado');
      }

      // Verificar tamanho do arquivo (máximo 500KB para base64)
      // Firestore tem limite de 1MB por campo, então limitamos a 500KB
      final fileSize = await imageFile.length();
      if (fileSize > 500 * 1024) {
        throw Exception(
          'A imagem é muito grande. Tamanho máximo: 500KB.\n'
          'Tente comprimir a imagem antes de fazer upload.',
        );
      }

      print('Convertendo imagem para base64...');

      // Ler o arquivo e converter para base64
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);

      // Criar uma URL de dados (data URL) que pode ser usada diretamente
      final dataUrl = 'data:image/jpeg;base64,$base64String';

      print(
        'Imagem convertida com sucesso. Tamanho: ${base64String.length} caracteres',
      );

      return dataUrl;
    } catch (e) {
      print('Erro ao processar imagem: $e');
      if (e.toString().contains('muito grande')) {
        rethrow;
      }
      throw Exception('Erro ao processar a imagem: ${e.toString()}');
    }
  }

  // Deletar foto de perfil antiga (não necessário com base64, mas mantido para compatibilidade)
  Future<void> deleteProfilePicture(String? imageUrl) async {
    // Com base64, a imagem é armazenada no Firestore
    // Não há necessidade de deletar arquivos separados
    // A atualização do campo no Firestore já substitui a imagem antiga
    return;
  }
}
