import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color mintPrimary = Color(0xFF10B981); // #10B981 Mint Green
  static const Color mintLight = Color(0xFFECFDF5);   // 100 tint
  static const Color mintDark = Color(0xFF059669);    // 600 shade
  static const Color mintAccent = Color(0xFF34D399);  // 400 highlight

  // Secondary Palette
  static const Color indigoSecondary = Color(0xFF6366F1); // #6366F1 Soft Indigo
  static const Color indigoLight = Color(0xFFEEF2FF);     // Soft indigo tint
  static const Color indigoDark = Color(0xFF4F46E5);      // Deep indigo

  // Background & Surfaces
  static const Color background = Color(0xFFF8F7FC);  // Very light lavender/off-white
  static const Color cardSurface = Color(0xFFFFFFFF); // Clean pure white
  static const Color cardSurfaceSecondary = Color(0xFFF4F3FA); // Subtle tint
  static const Color cardBorder = Color(0xFFEBE8F5);  // Delicate border color

  // Typography / Text Colors
  static const Color textPrimary = Color(0xFF172033); // Dark navy
  static const Color textSecondary = Color(0xFF6B7280); // Muted blue-grey
  static const Color textTertiary = Color(0xFF9CA3AF); // Light grey hint
  static const Color textInverse = Color(0xFFFFFFFF); // White text

  // Semantic & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color purpleLight = Color(0xFFF3E8FF);
  static const Color purpleAccent = Color(0xFF8B5CF6);

  // Dark Mode Palette (Dark Navy, lighter dark surfaces, mint accents)
  static const Color darkBackground = Color(0xFF0B1120);       // Deep navy background
  static const Color darkCardSurface = Color(0xFF162032);      // Dark slate navy surface
  static const Color darkCardSurfaceSecondary = Color(0xFF1F2D44); // Slightly elevated dark card
  static const Color darkCardBorder = Color(0xFF26354D);       // Dark subtle border
  static const Color darkTextPrimary = Color(0xFFF1F5F9);      // Off-white / bright slate
  static const Color darkTextSecondary = Color(0xFF94A3B8);    // Muted slate text
  static const Color darkTextTertiary = Color(0xFF64748B);     // Dim muted slate
  static const Color darkMintLight = Color(0xFF064E3B);        // Deep mint tint for dark mode
  static const Color darkIndigoLight = Color(0xFF1E1B4B);      // Deep indigo tint for dark mode

  // Shadows
  static const Color shadowColor = Color(0x0F172033);
  static const Color shadowMedium = Color(0x1A172033);
}

