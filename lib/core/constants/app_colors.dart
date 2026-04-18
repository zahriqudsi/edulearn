import 'package:flutter/material.dart';

class AppColors {
  // Premium Primary Palette (Indigo & Violet hue)
  static const Color primary = Color(0xFF4F46E5); // Vibrant Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF312E81);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800

  // Accents & Info
  static const Color accent = Color(0xFF8B5CF6); // Violet
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFF43F5E); // Rose

  // Text Colors
  static const Color textMainLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textMainDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Glassmorphism effect colors (Light & Dark)
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  
  static const Color glassDark = Color(0x33000000);
  static const Color glassBorderDark = Color(0x1AFFFFFF);
  
  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient premiumDarkGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}



