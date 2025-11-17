import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    // Primária: Laranja moderno e vibrante (cor principal)
    primary: Color(0xFFFF6B35), // Laranja vibrante e acolhedor
    onPrimary: Colors.white,
    // Secundária: Azul complementar harmonioso (cor de apoio)
    secondary: Color(0xFF4A90E2), // Azul suave e profissional
    onSecondary: Colors.white,
    // Terciária: Tom neutro para elementos de apoio
    tertiary: Color(0xFFF4A261), // Laranja mais claro
    onTertiary: Color(0xFF2A2A2A),
    // Background: Neutro e suave
    surface: Colors.white,
    onSurface: Color(0xFF1A1A1A), // Preto suave para texto
    // Background geral: Cinza muito claro
    background: Color(0xFFF8F9FA),
    onBackground: Color(0xFF1A1A1A),
    // Superfície variante: Cinza muito claro
    surfaceVariant: Color(0xFFF0F0F0),
    onSurfaceVariant: Color(0xFF5A5A5A),
    // Erro
    error: Color(0xFFE63946),
    onError: Colors.white,
    // Outros
    outline: Color(0xFFD0D0D0),
    shadow: Color(0x1A000000), // 10% de opacidade
  ),
  // Estilo do AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFF6B35),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  // Estilo dos cards
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  // Estilo dos botões elevados
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF6B35),
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  // Estilo dos inputs
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE63946)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  // Estilo dos floating action buttons
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFF6B35),
    foregroundColor: Colors.white,
    elevation: 4,
  ),
);
