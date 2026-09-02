import 'package:get/get.dart';

import '../../../core/utils/app_failure.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../data/models/exam_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/exam_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

enum ExamSelectionStatus { loading, loaded, empty, error }

class ExamSelectionController extends GetxController {
  final ExamRepository _examRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  ExamSelectionController({
    ExamRepository? examRepository,
    UserRepository? userRepository,
    AuthRepository? authRepository,
  })  : _examRepository = examRepository ?? ExamRepository(),
        _userRepository = userRepository ?? UserRepository(),
        _authRepository = authRepository ?? AuthRepository();

  final status = ExamSelectionStatus.loading.obs;
  final errorMessage = RxnString();
  final exams = <ExamModel>[].obs;
  final selectedExamId = RxnString();
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadExams();
  }

  Future<void> loadExams() async {
    try {
      status.value = ExamSelectionStatus.loading;
      final result = await _examRepository.fetchPublishedExams();
      exams.assignAll(result);
      status.value = result.isEmpty
          ? ExamSelectionStatus.empty
          : ExamSelectionStatus.loaded;
    } catch (e) {
      errorMessage.value = AppFailure.from(e).friendlyMessage;
      status.value = ExamSelectionStatus.error;
    }
  }

  void selectExam(String examId) {
    selectedExamId.value = examId;
  }

  Future<void> confirmSelection() async {
    final examId = selectedExamId.value;
    final uid = _authRepository.currentUser?.uid;
    if (examId == null || uid == null) return;

    try {
      isSubmitting.value = true;
      await _userRepository.setSelectedExam(uid, examId);
      Get.toNamed(Routes.studentProfile);
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage);
    } finally {
      isSubmitting.value = false;
    }
  }
}
