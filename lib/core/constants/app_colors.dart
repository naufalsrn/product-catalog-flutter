import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF498200);

  static const Color grey = Color(0xFF8A8A8A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gradientStart = Color(0xFFF5EED3);
  static const Color gradientEnd = Color(0xFF5D8055);

  static const LinearGradient entryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );
}
