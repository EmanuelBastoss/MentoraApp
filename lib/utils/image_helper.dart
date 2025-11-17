import 'package:flutter/material.dart';
import 'dart:convert';

class ImageHelper {
  // Verifica se a string é uma data URL (base64)
  static bool isDataUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('data:image/');
  }

  // Extrai o base64 de uma data URL
  static String? extractBase64(String dataUrl) {
    if (!isDataUrl(dataUrl)) return null;
    final parts = dataUrl.split(',');
    if (parts.length > 1) {
      return parts[1];
    }
    return null;
  }

  // Cria um ImageProvider que funciona com URLs normais e data URLs
  static ImageProvider? getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    if (isDataUrl(imageUrl)) {
      // É uma data URL (base64)
      final base64 = extractBase64(imageUrl);
      if (base64 != null) {
        try {
          final bytes = base64Decode(base64);
          return MemoryImage(bytes);
        } catch (e) {
          print('Erro ao decodificar base64: $e');
          return null;
        }
      }
    } else {
      // É uma URL normal
      return NetworkImage(imageUrl);
    }
    return null;
  }
}

