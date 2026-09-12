import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';
import '../../widgets/gradient_background.dart';
import '../home/home_screen.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 3),
                Image.asset('assets/images/easy_shop_logo.png', width: 180),
                Text('Welcome', style: AppTextStyles.bold(fontSize: 20)),
                const SizedBox(height: 8),
                Text(
                  'Discover everything you need, all in one place.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.medium(fontSize: 14),
                ),
                const Spacer(flex: 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Text('Enter Catalog'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
