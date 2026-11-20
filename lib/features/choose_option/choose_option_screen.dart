import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/option_card.dart';

class ChooseOptionScreen extends StatelessWidget {
  const ChooseOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Vibe Match'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose your option',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'How should we find your vibe?',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 190,
                          child: OptionCard(
                            icon: Icons.image_rounded,
                            iconColor: const Color(0xFF5C4BDB),
                            background: const Color(0xFFF3E8FF),
                            title: 'Upload a picture',
                            subtitle: 'from gallery or take a photo',
                            onTap: () => context.push('/upload-photo'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 190,
                          child: OptionCard(
                            icon: Icons.emoji_emotions_rounded,
                            iconColor: const Color(0xFFFB8C00),
                            background: const Color(0xFFFFF3D6),
                            title: 'Select a mood',
                            subtitle: 'Choose how you feel',
                            onTap: () => context.push('/select-mood'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}