import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/accuracy_ring.dart';
import '../../../routes/app_routes.dart';
import '../controllers/assessment_controller.dart';

/// §23/§56: the assessment result screen. Leads with a celebratory tier
/// reveal rather than a bare score -- per the final product principle, we
/// don't just say "18/30", we make the moment feel earned before pointing
/// to what's next.
class AssessmentResultView extends GetView<AssessmentController> {
  const AssessmentResultView({super.key});

  ({String emoji, String headline, Color color}) _tierFor(double accuracy) {
    if (accuracy >= 71) {
      return (emoji: '🏆', headline: 'Excellent Start!', color: AppColors.strong);
    }
    if (accuracy >= 41) {
      return (emoji: '💪', headline: 'Solid Effort!', color: AppColors.average);
    }
    return (emoji: '🎯', headline: 'Great First Step!', color: AppColors.primary);
  }

  @override
  Widget build(BuildContext context) {
    final result = controller.result!;
    final tier = _tierFor(result.accuracy);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Result'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Text(tier.emoji, textAlign: TextAlign.center, style: const TextStyle(fontSize: 56)),
            ),
            const SizedBox(height: 12),
            Text(
              tier.headline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: tier.color),
            ),
            const SizedBox(height: 24),
            Center(
              child: AccuracyRing(value: result.accuracy, size: 160, color: tier.color),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Overall Accuracy',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                    child: _StatTile(
                        label: 'Correct',
                        value: '${result.correctAnswers}',
                        color: AppColors.strong)),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatTile(
                        label: 'Incorrect',
                        value: '${result.incorrectAnswers}',
                        color: AppColors.weak)),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatTile(
                        label: 'Skipped',
                        value: '${result.unanswered}',
                        color: AppColors.insufficientData)),
              ],
            ),
            const SizedBox(height: 12),
            _StatTile(
              label: 'Score',
              value: '${result.score} marks',
              color: AppColors.primary,
              wide: true,
            ),
            const SizedBox(height: 32),
            Text(
              'We\'ve broken this down by subject, chapter, and topic so you '
              'know exactly what to study next.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.goToStrongWeakAreas,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('See Strong & Weak Areas'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Get.toNamed(Routes.answerReview),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Review All Answers'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool wide;
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
