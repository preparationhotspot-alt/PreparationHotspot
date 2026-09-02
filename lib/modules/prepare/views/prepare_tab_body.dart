import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// §19-§21: Prepare (Subjects > Chapters > Topics > Notes) -- not built
/// yet, needs the subjects/chapters/topics catalog collections (Phase 6).
class PrepareTabBody extends StatelessWidget {
  const PrepareTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_outlined, size: 56, color: AppColors.primary),
              SizedBox(height: 16),
              Text('Prepare Is On Its Way',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text(
                'Browse subjects, chapters, and topics with notes and '
                'formula sheets -- coming soon.',
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
