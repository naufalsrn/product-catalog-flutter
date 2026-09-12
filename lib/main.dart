import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/login/entry_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalog',
      theme: AppTheme.light,
      home: const EntryScreen(),
    );
  }
}
