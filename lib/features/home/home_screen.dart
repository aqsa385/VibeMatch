import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder. The real home / choose-option screen comes next.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VibeMatch')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home screen coming soon'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.push('/choose-option'),
              child: const Text('Start Vibe Match'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
