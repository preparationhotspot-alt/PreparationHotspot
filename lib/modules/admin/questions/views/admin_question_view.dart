import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/admin_question_model.dart';
import '../controllers/admin_question_controller.dart';
import 'question_form_dialog.dart';
import 'question_import_dialog.dart';

class AdminQuestionView extends GetView<AdminQuestionController> {
  const AdminQuestionView({super.key});

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
                Text('Question Bank', style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                OutlinedButton.icon(
                  style: AppTheme.compactOutlinedButton,
                  onPressed: () async {
                    final parsed = await controller.pickAndParseCsv();
                    if (parsed != null) showImportPreviewDialog(controller, parsed);
                  },
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Import CSV'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: AppTheme.compactButton,
                  onPressed: () => showQuestionFormDialog(controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Obx(() => DropdownButton<String?>(
                      value: controller.selectedExamId.value,
                      hint: const Text('All exams'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All exams')),
                        ...controller.exams
                            .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))),
                      ],
                      onChanged: controller.filterByExam,
                    )),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search question text or topic...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                    onChanged: (v) => controller.searchText.value = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = controller.filteredQuestions;
                if (list.isEmpty) {
                  return const Center(child: Text('No questions found.'));
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _QuestionRow(question: list[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final AdminQuestionModel question;
  const _QuestionRow({required this.question});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminQuestionController>();
    final isPublished = question.status == 'published';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.questionText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    _Tag(question.examId),
                    _Tag(question.subjectName),
                    _Tag(question.chapterName),
                    _Tag(question.difficulty),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: isPublished,
            onChanged: (_) => controller.toggleStatus(question),
            activeThumbColor: AppColors.strong,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => showQuestionFormDialog(controller, existing: question),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
            onPressed: () => controller.deleteQuestion(question),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
    );
  }
}
