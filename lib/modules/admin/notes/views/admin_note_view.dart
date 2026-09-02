import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/note_model.dart';
import '../controllers/admin_note_controller.dart';
import 'note_form_dialog.dart';

class AdminNoteView extends GetView<AdminNoteController> {
  const AdminNoteView({super.key});

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
                Text('Notes', style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                ElevatedButton.icon(
                  style: AppTheme.compactButton,
                  onPressed: () => showNoteFormDialog(controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Note'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButton<String?>(
                  value: controller.selectedExamId.value,
                  hint: const Text('All exams'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All exams')),
                    ...controller.exams
                        .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))),
                  ],
                  onChanged: (v) => controller.selectedExamId.value = v,
                )),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = controller.filteredNotes;
                if (list.isEmpty) {
                  return const Center(child: Text('No notes yet. Add one to get started.'));
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _NoteRow(note: list[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final NoteModel note;
  const _NoteRow({required this.note});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminNoteController>();
    final isPublished = note.status == 'published';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            note.contentType == 'file' ? Icons.picture_as_pdf_outlined : Icons.article_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${note.subjectName} · ${note.chapterName} · ${note.topicName}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: isPublished,
            onChanged: (_) => controller.toggleStatus(note),
            activeThumbColor: AppColors.strong,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => showNoteFormDialog(controller, existing: note),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
            onPressed: () => controller.deleteNote(note),
          ),
        ],
      ),
    );
  }
}
