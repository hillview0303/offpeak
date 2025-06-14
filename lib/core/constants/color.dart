import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (메인 컬러 - 연한 올리브 그린)
  static const Color primary = Color(0xFFA1C780);
  static const Color primaryLight = Color(0xFFB8D69A);
  static const Color primaryDark = Color(0xFF8BB566);

  // Secondary Colors (포인트 컬러 - 짙은 그린)
  static const Color secondary = Color(0xFF6E947A);
  static const Color secondaryLight = Color(0xFF85A691);
  static const Color secondaryDark = Color(0xFF5A7A63);

  // Background Colors (자연스러운 배경색)
  static const Color background = Color(0xFFF8F9F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFCFDFA);

  // Text Colors (그린 톤에 어울리는 텍스트)
  static const Color textPrimary = Color(0xFF2D3E2F);
  static const Color textSecondary = Color(0xFF556B57);
  static const Color textHint = Color(0xFF9BB19C);
  static const Color textDisabled = Color(0xFFB8C8B9);

  // Status Colors (자연스러운 상태 색상)
  static const Color success = Color(0xFF7CB342);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);

  // Neutral Colors (따뜻한 뉴트럴 톤)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF8E9E8F);
  static const Color greyLight = Color(0xFFD6DDD7);
  static const Color greyDark = Color(0xFF4A5A4C);

  // Border Colors (부드러운 경계선)
  static const Color border = Color(0xFFD6DDD7);
  static const Color borderFocus = Color(0xFFA1C780);
  static const Color borderError = Color(0xFFE57373);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x33000000);

  // Gradient Colors (자연스러운 그라데이션)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 부드러운 그라데이션 (배경용)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9F6), Color(0xFFEDF2EA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );


}
