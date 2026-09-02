import 'package:flutter/material.dart';

import '../../data/models/user_performance_model.dart';
import '../theme/app_colors.dart';

/// Renders one status bucket (Strong / Average / Weak / Insufficient Data)
/// grouped as Subject -> Chapter (subtopic) -> topics (§15), so it reads as
/// the exam's actual hierarchy rather than a flat mixed list. Shared by any
/// screen that shows a student's topic-level performance (the post-submit
/// flow, the standalone "My Performance" screen, and the admin panel's
/// student detail view -- each app passes its own [onTapTopic] since the
/// student and admin apps have entirely separate route tables).
class TopicAreaSection extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final Color bgColor;
  final List<UserPerformanceModel> topics;
  final String? subtitle;
  final void Function(UserPerformanceModel topic)? onTapTopic;

  const TopicAreaSection({
    super.key,
    required this.title,
    required this.emoji,
    required this.color,
    required this.bgColor,
    required this.topics,
    this.subtitle,
    this.onTapTopic,
  });

  Map<String, Map<String, List<UserPerformanceModel>>> _grouped() {
    final grouped = <String, Map<String, List<UserPerformanceModel>>>{};
    for (final topic in topics) {
      final subjectGroup = grouped.putIfAbsent(topic.subjectName, () => {});
      final chapterName = (topic.chapterName?.isNotEmpty ?? false)
          ? topic.chapterName!
          : (topic.topicName ?? 'General');
      subjectGroup.putIfAbsent(chapterName, () => []).add(topic);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 12),
          for (final subjectEntry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(subjectEntry.key,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary)),
            ),
            for (final chapterEntry in subjectEntry.value.entries) ...[
              if (chapterEntry.key != subjectEntry.key)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(chapterEntry.key,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                ),
              for (final topic in chapterEntry.value)
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTapTopic == null ? null : () => onTapTopic!(topic),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(topic.topicName ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                '${topic.correctAnswers} correct, '
                                '${topic.incorrectAnswers} incorrect of ${topic.attemptedQuestions} attempted',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          topic.isInsufficientData
                              ? '${topic.attemptedQuestions}/3'
                              : '${topic.accuracy.toStringAsFixed(0)}%',
                          style:
                              TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
