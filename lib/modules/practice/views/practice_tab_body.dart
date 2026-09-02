import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// §22-§23: Practice Questions -- not built yet, needs the
/// practice_sessions engine (Phase 7).
class PracticeTabBody extends StatelessWidget {
  const PracticeTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_note_outlined, size: 56, color: AppColors.primary),
              SizedBox(height: 16),
              Text('Practice Is On Its Way',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text(
                'Recommended, subject, chapter, and topic practice modes '
                'built from your weak areas -- coming soon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
