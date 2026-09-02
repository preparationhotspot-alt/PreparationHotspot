import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/exam_model.dart';
import '../controllers/admin_exam_controller.dart';

Future<void> showExamFormDialog({
  required AdminExamController controller,
  ExamModel? existing,
}) {
  final nameController = TextEditingController(text: existing?.name);
  final descriptionController = TextEditingController(text: existing?.description);
  final displayOrderController = TextEditingController(
    text: '${existing?.displayOrder ?? controller.exams.length + 1}',
  );

  return Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Add Exam' : 'Edit Exam',
                  style: Theme.of(Get.context!).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Exam Name'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: displayOrderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Display Order'),
              ),
              const SizedBox(height: 24),
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
                                  final displayOrder =
                                      int.tryParse(displayOrderController.text) ?? 0;
                                  final ok = existing == null
                                      ? await controller.createExam(
                                          name: nameController.text,
                                          description: descriptionController.text,
                                          displayOrder: displayOrder,
                                        )
                                      : await controller.updateExam(
                                          existing.id,
                                          name: nameController.text,
                                          description: descriptionController.text,
                                          displayOrder: displayOrder,
                                        );
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
