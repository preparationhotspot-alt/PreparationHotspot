import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/admin_question_model.dart';
import '../controllers/admin_question_controller.dart';
import '../utils/question_csv_parser.dart';

/// Manual single-question form -- covers `single_choice` only (matching
/// the §37 CSV template's scope). Other question types can still be
/// entered via bulk import once the CSV format is extended for them.
void showQuestionFormDialog(AdminQuestionController controller, {AdminQuestionModel? existing}) {
  final examIdController = TextEditingController(text: existing?.examId);
  final subjectController = TextEditingController(text: existing?.subjectName);
  final chapterController = TextEditingController(text: existing?.chapterName);
  final topicController = TextEditingController(text: existing?.topicName);
  final questionController = TextEditingController(text: existing?.questionText);
  final optionAController =
      TextEditingController(text: existing?.options.elementAtOrNull(0)?['text']);
  final optionBController =
      TextEditingController(text: existing?.options.elementAtOrNull(1)?['text']);
  final optionCController =
      TextEditingController(text: existing?.options.elementAtOrNull(2)?['text']);
  final optionDController =
      TextEditingController(text: existing?.options.elementAtOrNull(3)?['text']);
  final explanationController = TextEditingController(text: existing?.explanation);
  final marksController = TextEditingController(text: '${existing?.marks ?? 4}');
  final negativeMarksController = TextEditingController(text: '${existing?.negativeMarks ?? 1}');
  final sourceController = TextEditingController(text: existing?.source);
  final yearController = TextEditingController(text: existing?.year?.toString() ?? '');

  final difficulty = (existing?.difficulty ?? 'medium').obs;
  final correctAnswer = (existing?.correctAnswer as String? ?? 'A').obs;
  final isSaving = false.obs;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Add Question' : 'Edit Question',
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
                      Obx(() => DropdownButtonFormField<String>(
                            initialValue: difficulty.value,
                            decoration: const InputDecoration(labelText: 'Difficulty'),
                            items: const ['easy', 'medium', 'hard']
                                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                .toList(),
                            onChanged: (v) => difficulty.value = v ?? 'medium',
                          )),
                      const SizedBox(height: 12),
                      TextField(
                        controller: questionController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Question Text'),
                      ),
                      const SizedBox(height: 12),
                      for (final entry in [
                        ('A', optionAController),
                        ('B', optionBController),
                        ('C', optionCController),
                        ('D', optionDController),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextField(
                            controller: entry.$2,
                            decoration: InputDecoration(labelText: 'Option ${entry.$1}'),
                          ),
                        ),
                      Obx(() => DropdownButtonFormField<String>(
                            initialValue: correctAnswer.value,
                            decoration: const InputDecoration(labelText: 'Correct Answer'),
                            items: const ['A', 'B', 'C', 'D']
                                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                                .toList(),
                            onChanged: (v) => correctAnswer.value = v ?? 'A',
                          )),
                      const SizedBox(height: 12),
                      TextField(
                        controller: explanationController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Explanation'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                                  controller: marksController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Marks'))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                                  controller: negativeMarksController,
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      const InputDecoration(labelText: 'Negative Marks'))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                                  controller: sourceController,
                                  decoration: const InputDecoration(labelText: 'Source'))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                                  controller: yearController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Year'))),
                        ],
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
                          onPressed: isSaving.value
                              ? null
                              : () async {
                                  if (examIdController.text.isEmpty ||
                                      questionController.text.isEmpty) {
                                    return;
                                  }
                                  isSaving.value = true;
                                  final subjectId = slugify(subjectController.text);
                                  final chapterId = slugify(chapterController.text);
                                  final topicId = slugify(topicController.text);
                                  final data = {
                                    'examId': examIdController.text,
                                    'subjectId': subjectId,
                                    'subjectName': subjectController.text,
                                    'chapterId': chapterId,
                                    'chapterName': chapterController.text,
                                    'topicId': topicId,
                                    'topicName': topicController.text,
                                    'questionType': 'single_choice',
                                    'difficulty': difficulty.value,
                                    'questionText': questionController.text,
                                    'questionImage': null,
                                    'options': [
                                      {'key': 'A', 'text': optionAController.text},
                                      {'key': 'B', 'text': optionBController.text},
                                      {'key': 'C', 'text': optionCController.text},
                                      {'key': 'D', 'text': optionDController.text},
                                    ],
                                    'correctAnswer': correctAnswer.value,
                                    'explanation': explanationController.text,
                                    'marks': num.tryParse(marksController.text) ?? 4,
                                    'negativeMarks':
                                        num.tryParse(negativeMarksController.text) ?? 1,
                                    'source': sourceController.text,
                                    'year': int.tryParse(yearController.text),
                                    'status': existing?.status ?? 'draft',
                                  };
                                  final ok =
                                      await controller.saveQuestion(existing?.id, data);
                                  isSaving.value = false;
                                  if (ok) Get.back();
                                },
                          child: isSaving.value
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
