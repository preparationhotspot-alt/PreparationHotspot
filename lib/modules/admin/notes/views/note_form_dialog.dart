import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/note_model.dart';
import '../controllers/admin_note_controller.dart';

void showNoteFormDialog(AdminNoteController controller, {NoteModel? existing}) {
  final examIdController = TextEditingController(text: existing?.examId);
  final subjectController = TextEditingController(text: existing?.subjectName);
  final chapterController = TextEditingController(text: existing?.chapterName);
  final topicController = TextEditingController(text: existing?.topicName);
  final titleController = TextEditingController(text: existing?.title);
  final contentController = TextEditingController(text: existing?.content);
  final fileUrlController = TextEditingController(text: existing?.fileUrl);
  final displayOrderController =
      TextEditingController(text: '${existing?.displayOrder ?? controller.notes.length + 1}');

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Add Note' : 'Edit Note',
                  style: Theme.of(Get.context!).textTheme.titleLarge),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => DropdownButtonFormField<String>(
                            initialValue: controller.exams.any((e) => e.id == examIdController.text)
                                ? examIdController.text
                                : null,
                            decoration: const InputDecoration(labelText: 'Exam'),
                            items: controller.exams
                                .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                                .toList(),
                            onChanged: (v) => examIdController.text = v ?? '',
                          )),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                                  controller: subjectController,
                                  decoration: const InputDecoration(labelText: 'Subject'))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                                  controller: chapterController,
                                  decoration: const InputDecoration(labelText: 'Chapter'))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: topicController,
                        decoration: const InputDecoration(labelText: 'Topic'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Note Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: contentController,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          labelText: 'Content (plain text / markdown)',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: fileUrlController,
                        decoration: const InputDecoration(
                          labelText: 'PDF / Image URL (optional)',
                          helperText: 'Upload the file to Firebase Storage separately, '
                              'then paste its download URL here.',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: displayOrderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Display Order'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : () async {
                                  if (examIdController.text.isEmpty ||
                                      titleController.text.isEmpty) {
                                    return;
                                  }
                                  final data = {
                                    'examId': examIdController.text,
                                    'subjectName': subjectController.text,
                                    'chapterName': chapterController.text,
                                    'topicName': topicController.text,
                                    'title': titleController.text,
                                    'content': contentController.text,
                                    'contentType':
                                        fileUrlController.text.isEmpty ? 'text' : 'file',
                                    'fileUrl': fileUrlController.text.isEmpty
                                        ? null
                                        : fileUrlController.text,
                                    'displayOrder':
                                        int.tryParse(displayOrderController.text) ?? 0,
                                    'status': existing?.status ?? 'draft',
                                  };
                                  final ok = await controller.saveNote(existing?.id, data);
                                  if (ok) Get.back();
                                },
                          child: controller.isSaving.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Save'),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
