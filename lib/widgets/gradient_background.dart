import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.entryGradient),
      child: SizedBox.expand(child: child),
    );
  }
}
