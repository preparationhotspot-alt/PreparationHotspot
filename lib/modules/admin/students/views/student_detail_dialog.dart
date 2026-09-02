import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/topic_area_section.dart';
import '../../../../data/models/app_user_model.dart';
import '../../../../data/models/user_performance_model.dart';
import '../../../../data/repositories/performance_repository.dart';

void showStudentDetailDialog(AppUserModel student, String examName) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _StudentDetailBody(student: student, examName: examName),
        ),
      ),
    ),
  );
}

class _StudentDetailBody extends StatefulWidget {
  final AppUserModel student;
  final String examName;
  const _StudentDetailBody({required this.student, required this.examName});

  @override
  State<_StudentDetailBody> createState() => _StudentDetailBodyState();
}

class _StudentDetailBodyState extends State<_StudentDetailBody> {
  final _performanceRepository = PerformanceRepository();
  List<UserPerformanceModel>? _topics;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final examId = widget.student.selectedExamId;
    if (examId == null) {
      setState(() => _loading = false);
      return;
    }
    final topics = await _performanceRepository.fetchTopicPerformance(
      userId: widget.student.uid,
      examId: examId,
    );
    setState(() {
      _topics = topics;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.fullName, style: Theme.of(context).textTheme.titleLarge),
                  Text(student.email,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _InfoChip(label: 'Exam', value: widget.examName),
            _InfoChip(label: 'Target Year', value: '${student.targetExamYear ?? "-"}'),
            _InfoChip(
                label: 'Accuracy', value: '${student.overallAccuracy.toStringAsFixed(0)}%'),
            _InfoChip(label: 'Questions', value: '${student.questionsAttempted}'),
            _InfoChip(label: 'Tests', value: '${student.testsAttempted}'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : (widget.student.selectedExamId == null)
                  ? const Center(child: Text('This student has not selected an exam yet.'))
                  : (_topics?.isEmpty ?? true)
                      ? const Center(
                          child: Text('No performance data yet for this student.'))
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _section('Needs Improvement', '🎯', AppColors.weak,
                                  AppColors.weakBg, 'weak'),
                              _section('Average', '💪', AppColors.average,
                                  AppColors.averageBg, 'average'),
                              _section('Strong', '🏆', AppColors.strong,
                                  AppColors.strongBg, 'strong'),
                            ],
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _section(String title, String emoji, Color color, Color bg, String status) {
    final topics = _topics!.where((t) => t.performanceStatus == status).toList();
    if (topics.isEmpty) return const SizedBox.shrink();
    return TopicAreaSection(title: title, emoji: emoji, color: color, bgColor: bg, topics: topics);
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
