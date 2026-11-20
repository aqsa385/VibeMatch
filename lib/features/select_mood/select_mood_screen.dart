import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/mood.dart';
import '../result/result_screen.dart';
import 'widgets/mood_card.dart';

class SelectMoodScreen extends StatefulWidget {
  const SelectMoodScreen({super.key});

  @override
  State<SelectMoodScreen> createState() => _SelectMoodScreenState();
}

class _SelectMoodScreenState extends State<SelectMoodScreen> {
  Mood? _selected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Mood'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              Text('How are you feeling today?', style: textTheme.titleMedium),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: Mood.values.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, i) {
                    final mood = Mood.values[i];
                    return MoodCard(
                      mood: mood,
                      selected: _selected == mood,
                      onTap: () => setState(() => _selected = mood),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _selected == null
                      ? null
                      : () => context.push('/result',
                      extra: ResultArgs(mood: _selected)),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}