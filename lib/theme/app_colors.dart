import 'package:flutter/material.dart';

// App color scheme with antique/vintage theme
class AppColors {
  // Primary Colors - Antique Gold & Bronze
  static const Color primary = Color(0xFFB8860B); // Dark Goldenrod
  static const Color primaryLight = Color(0xFFDAA520); // Goldenrod
  static const Color primaryDark = Color(0xFF8B6914); // Darker Gold
  
  // Secondary Colors - Rich Brown & Mahogany
  static const Color secondary = Color(0xFF5D4037); // Brown
  static const Color secondaryLight = Color(0xFF8B6F47); // Light Brown
  static const Color secondaryDark = Color(0xFF3E2723); // Dark Brown
  
  // Accent Colors
  static const Color accent = Color(0xFFCD853F); // Peru (Antique Copper)
  static const Color accentLight = Color(0xFFDEB887); // Burlywood
  
  // Background Colors
  static const Color background = Color(0xFFFAF8F3); // Warm Off-White
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color cardBackground = Color(0xFFF5F1E8); // Light Cream
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2C2416); // Dark Brown
  static const Color textSecondary = Color(0xFF6D5D4B); // Medium Brown
  static const Color textTertiary = Color(0xFF9E8B7B); // Light Brown
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFD32F2F); // Red
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color info = Color(0xFF2196F3); // Blue
  
  // Bidding Status Colors
  static const Color winning = Color(0xFF4CAF50); // Green
  static const Color outbid = Color(0xFFFF5722); // Deep Orange
  static const Color ended = Color(0xFF757575); // Grey
  
  // Border & Divider Colors
  static const Color border = Color(0xFFD4C4B0); // Light Brown
  static const Color divider = Color(0xFFE8DFD0); // Very Light Brown
  
  // Shadow Color
  static const Color shadow = Color(0x1A000000); // Black with 10% opacity
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
