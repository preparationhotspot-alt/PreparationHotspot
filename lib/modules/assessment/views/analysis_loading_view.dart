import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Brief transitional screen shown while the result/performance data for
/// the just-submitted attempt is being fetched (§56: ANALYSIS step).
class AnalysisLoadingView extends StatelessWidget {
  const AnalysisLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Analyzing your answers...', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
