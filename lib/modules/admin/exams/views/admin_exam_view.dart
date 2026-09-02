import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/exam_model.dart';
import '../controllers/admin_exam_controller.dart';
import 'exam_form_dialog.dart';

class AdminExamView extends GetView<AdminExamController> {
  const AdminExamView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Exams', style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                ElevatedButton.icon(
                  style: AppTheme.compactButton,
                  onPressed: () => showExamFormDialog(controller: controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exam'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.exams.isEmpty) {
                  return const Center(child: Text('No exams yet. Add one to get started.'));
                }
                return ListView.separated(
                  itemCount: controller.exams.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _ExamRow(exam: controller.exams[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamRow extends StatelessWidget {
  final ExamModel exam;
  const _ExamRow({required this.exam});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminExamController>();
    final isPublished = exam.status == 'published';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('#${exam.displayOrder}',
                style: const TextStyle(fontSize: 12, color: AppColors.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(exam.slug,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (exam.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(exam.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
              ],
            ),
          ),
          Switch(
            value: isPublished,
            onChanged: (_) => controller.toggleStatus(exam),
            activeThumbColor: AppColors.strong,
          ),
          Text(isPublished ? 'Published' : 'Draft',
              style: TextStyle(
                  fontSize: 12,
                  color: isPublished ? AppColors.strong : AppColors.textSecondary)),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => showExamFormDialog(controller: controller, existing: exam),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
            onPressed: () => controller.deleteExam(exam),
          ),
        ],
      ),
    );
  }
}
