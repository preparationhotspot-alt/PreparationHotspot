import 'package:get/get.dart';

import '../../../../core/utils/app_failure.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../data/models/admin_question_model.dart';
import '../../../../data/models/exam_model.dart';
import '../../../../data/models/mock_test_model.dart';
import '../../../../data/repositories/admin_question_repository.dart';
import '../../../../data/repositories/exam_repository.dart';
import '../../../../data/repositories/mock_test_repository.dart';

class AdminMockTestController extends GetxController {
  final MockTestRepository _mockTestRepository;
  final ExamRepository _examRepository;
  final AdminQuestionRepository _questionRepository;

  AdminMockTestController({
    MockTestRepository? mockTestRepository,
    ExamRepository? examRepository,
    AdminQuestionRepository? questionRepository,
  })  : _mockTestRepository = mockTestRepository ?? MockTestRepository(),
        _examRepository = examRepository ?? ExamRepository(),
        _questionRepository = questionRepository ?? AdminQuestionRepository();

  final exams = <ExamModel>[].obs;
  final mockTests = <MockTestModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExams();
    _mockTestRepository.watchMockTests().listen((list) {
      mockTests.assignAll(list);
      isLoading.value = false;
    });
  }

  Future<void> _loadExams() async {
    exams.assignAll(await _examRepository.fetchPublishedExams());
  }

  Future<List<AdminQuestionModel>> questionsForExam(String examId) {
    return _questionRepository.fetchQuestions(examId: examId);
  }

  Future<bool> saveMockTest(String? existingId, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      if (existingId == null) {
        await _mockTestRepository.createMockTest(data);
      } else {
        await _mockTestRepository.updateMockTest(existingId, data);
      }
      return true;
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage, title: 'Could not save test');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleStatus(MockTestModel test) async {
    final newStatus = test.status == 'published' ? 'draft' : 'published';
    try {
      await _mockTestRepository.setStatus(test.id, newStatus);
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage);
    }
  }

  Future<void> deleteMockTest(MockTestModel test) async {
    final confirmed = await AppDialogs.confirm(
      title: 'Delete "${test.name}"?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await _mockTestRepository.deleteMockTest(test.id);
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage);
    }
  }
}
