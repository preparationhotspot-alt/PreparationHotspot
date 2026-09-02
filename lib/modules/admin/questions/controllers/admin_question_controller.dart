import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_failure.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../data/models/admin_question_model.dart';
import '../../../../data/models/exam_model.dart';
import '../../../../data/repositories/admin_question_repository.dart';
import '../../../../data/repositories/exam_repository.dart';
import '../utils/question_csv_parser.dart';

class AdminQuestionController extends GetxController {
  final AdminQuestionRepository _questionRepository;
  final ExamRepository _examRepository;

  AdminQuestionController({
    AdminQuestionRepository? questionRepository,
    ExamRepository? examRepository,
  })  : _questionRepository = questionRepository ?? AdminQuestionRepository(),
        _examRepository = examRepository ?? ExamRepository();

  final exams = <ExamModel>[].obs;
  final questions = <AdminQuestionModel>[].obs;
  final selectedExamId = RxnString();
  final searchText = ''.obs;
  final isLoading = true.obs;
  final isImporting = false.obs;

  List<AdminQuestionModel> get filteredQuestions {
    final q = searchText.value.toLowerCase();
    if (q.isEmpty) return questions;
    return questions
        .where((question) =>
            question.questionText.toLowerCase().contains(q) ||
            question.topicName.toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadExams();
    loadQuestions();
  }

  Future<void> _loadExams() async {
    exams.assignAll(await _examRepository.fetchPublishedExams());
  }

  Future<void> loadQuestions() async {
    try {
      isLoading.value = true;
      final result = await _questionRepository.fetchQuestions(examId: selectedExamId.value);
      questions.assignAll(result);
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage);
    } finally {
      isLoading.value = false;
    }
  }

  void filterByExam(String? examId) {
    selectedExamId.value = examId;
    loadQuestions();
  }

  Future<void> toggleStatus(AdminQuestionModel question) async {
    final newStatus = question.status == 'published' ? 'draft' : 'published';
    try {
      await _questionRepository.setStatus(question.id, newStatus);
      await loadQuestions();
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage);
    }
  }

  Future<void> deleteQuestion(AdminQuestionModel question) async {
    final confirmed = await AppDialogs.confirm(
      title: 'Delete this question?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await _questionRepository.deleteQuestion(question.id);
      await loadQuestions();
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage);
    }
  }

  Future<bool> saveQuestion(String? existingId, Map<String, dynamic> data) async {
    try {
      if (existingId == null) {
        final id = 'q_${DateTime.now().microsecondsSinceEpoch}';
        await _questionRepository.createQuestion(id, data);
      } else {
        await _questionRepository.updateQuestion(existingId, data);
      }
      await loadQuestions();
      return true;
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage, title: 'Could not save question');
      return false;
    }
  }

  /// §37: pick a CSV and validate every row. Returns the parsed result for
  /// the caller to show a preview dialog before actually importing --
  /// nothing is written to Firestore here.
  Future<ParsedCsvResult?> pickAndParseCsv() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final csvContent = String.fromCharCodes(bytes);
    final publishedSlugs = exams.map((e) => e.id).toSet();
    final parsed = parseQuestionCsv(csvContent, publishedSlugs);

    if (parsed.validRows.isEmpty && parsed.failedRows.isEmpty) {
      AppDialogs.error('The CSV has no data rows.');
      return null;
    }
    return parsed;
  }

  Future<void> confirmImport(ParsedCsvResult result) async {
    if (result.validRows.isEmpty) return;
    try {
      isImporting.value = true;
      await _questionRepository.bulkUpsert(result.validRows);
      await loadQuestions();
      Get.back();
      AppDialogs.success(
        '${result.validRows.length} imported, ${result.failedRows.length} failed.',
        title: 'Import complete',
      );
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage, title: 'Import failed');
    } finally {
      isImporting.value = false;
    }
  }
}
