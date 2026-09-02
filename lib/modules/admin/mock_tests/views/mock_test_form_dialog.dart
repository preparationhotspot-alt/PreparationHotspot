import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/admin_question_model.dart';
import '../../../../data/models/mock_test_model.dart';
import '../controllers/admin_mock_test_controller.dart';

void showMockTestFormDialog(AdminMockTestController controller, {MockTestModel? existing}) {
  final nameController = TextEditingController(text: existing?.name);
  final durationController =
      TextEditingController(text: '${existing?.durationMinutes ?? 60}');
  final instructionsController = TextEditingController(text: existing?.instructions);
  final examId = (existing?.examId ?? controller.exams.firstOrNull?.id ?? '').obs;
  final testType = (existing?.testType ?? 'full_mock').obs;
  final selectedQuestionIds = <String>{...existing?.questionIds ?? []}.obs;
  final availableQuestions = <AdminQuestionModel>[].obs;
  final isLoadingQuestions = false.obs;

  Future<void> loadQuestions() async {
    if (examId.value.isEmpty) return;
    isLoadingQuestions.value = true;
    availableQuestions.assignAll(await controller.questionsForExam(examId.value));
    isLoadingQuestions.value = false;
  }

  loadQuestions();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Create Mock Test' : 'Edit Mock Test',
                  style: Theme.of(Get.context!).textTheme.titleLarge),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Test Name'),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => DropdownButtonFormField<String>(
                            initialValue: controller.exams.any((e) => e.id == examId.value)
                                ? examId.value
                                : null,
                            decoration: const InputDecoration(labelText: 'Exam'),
                            items: controller.exams
                                .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                                .toList(),
                            onChanged: (v) {
                              examId.value = v ?? '';
                              selectedQuestionIds.clear();
                              loadQuestions();
                            },
                          )),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => DropdownButtonFormField<String>(
                                  initialValue: testType.value,
                                  decoration: const InputDecoration(labelText: 'Test Type'),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'full_mock', child: Text('Full Mock Test')),
                                    DropdownMenuItem(
                                        value: 'subject_test', child: Text('Subject Test')),
                                    DropdownMenuItem(
                                        value: 'chapter_test', child: Text('Chapter Test')),
                                    DropdownMenuItem(
                                        value: 'previous_year', child: Text('Previous Year')),
                                  ],
                                  onChanged: (v) => testType.value = v ?? 'full_mock',
                                )),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: durationController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Duration (min)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: instructionsController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Instructions'),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => Text(
                          'Questions (${selectedQuestionIds.length} selected)',
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 260),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Obx(() {
                          if (isLoadingQuestions.value) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (availableQuestions.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No questions found for this exam.'),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: availableQuestions.length,
                            itemBuilder: (context, index) {
                              final q = availableQuestions[index];
                              return Obx(() => CheckboxListTile(
                                    dense: true,
                                    value: selectedQuestionIds.contains(q.id),
                                    title: Text(q.questionText,
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    subtitle: Text('${q.subjectName} · ${q.chapterName}',
                                        style: const TextStyle(fontSize: 11)),
                                    onChanged: (checked) {
                                      if (checked == true) {
                                        selectedQuestionIds.add(q.id);
                                      } else {
                                        selectedQuestionIds.remove(q.id);
                                      }
                                    },
                                  ));
                            },
                          );
                        }),
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
                                  if (nameController.text.isEmpty || examId.value.isEmpty) {
                                    return;
                                  }
                                  final data = {
                                    'name': nameController.text,
                                    'examId': examId.value,
                                    'testType': testType.value,
                                    'durationMinutes':
                                        int.tryParse(durationController.text) ?? 60,
                                    'instructions': instructionsController.text,
                                    'questionIds': selectedQuestionIds.toList(),
                                    'totalQuestions': selectedQuestionIds.length,
                                    'status': existing?.status ?? 'draft',
                                  };
                                  final ok =
                                      await controller.saveMockTest(existing?.id, data);
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
