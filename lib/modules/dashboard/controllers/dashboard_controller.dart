import 'package:get/get.dart';

import '../../../core/utils/app_failure.dart';
import '../../../data/models/app_user_model.dart';
import '../../../data/models/study_plan_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/exam_repository.dart';
import '../../../data/repositories/performance_repository.dart';
import '../../../data/repositories/study_plan_repository.dart';
import '../../../routes/app_routes.dart';

enum DashboardStatus { loading, loaded, error }

/// §18: Home Dashboard data source -- greeting, exam, recommended topics
/// (from the §17 rule-based study plan) and preparation stats. All figures
/// come from server-computed `users`/`user_performance`/`study_plans`
/// documents; nothing is calculated on-device (§30).
class DashboardController extends GetxController {
  final AuthRepository _authRepository;
  final ExamRepository _examRepository;
  final StudyPlanRepository _studyPlanRepository;
  final PerformanceRepository _performanceRepository;

  DashboardController({
    AuthRepository? authRepository,
    ExamRepository? examRepository,
    StudyPlanRepository? studyPlanRepository,
    PerformanceRepository? performanceRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _examRepository = examRepository ?? ExamRepository(),
        _studyPlanRepository = studyPlanRepository ?? StudyPlanRepository(),
        _performanceRepository = performanceRepository ?? PerformanceRepository();

  final status = DashboardStatus.loading.obs;
  final errorMessage = RxnString();

  AppUserModel? user;
  String examName = '';
  StudyPlanModel? studyPlan;
  int topicsMastered = 0;
  double preparationProgress = 0;

  List<StudyPlanItemModel> get recommendedTopics =>
      (studyPlan?.items ?? []).take(5).toList();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      status.value = DashboardStatus.loading;
      final uid = _authRepository.currentUser!.uid;
      final profile = await _authRepository.fetchUserProfile(uid);
      if (profile == null) {
        errorMessage.value = 'Could not load your profile.';
        status.value = DashboardStatus.error;
        return;
      }
      user = profile;

      final examId = profile.selectedExamId;
      if (examId == null) {
        status.value = DashboardStatus.loaded;
        return;
      }

      final examFuture = _examRepository.fetchExamById(examId);
      final planFuture = _studyPlanRepository.fetchPlan(userId: uid, examId: examId);
      final topicsFuture = _performanceRepository.fetchTopicPerformance(
        userId: uid,
        examId: examId,
      );

      final exam = await examFuture;
      studyPlan = await planFuture;
      final topics = await topicsFuture;

      examName = exam?.name ?? '';
      topicsMastered = topics.where((t) => t.isStrong).length;
      final ratedTopics = topics.where((t) => !t.isInsufficientData).length;
      preparationProgress =
          topics.isEmpty ? 0 : (ratedTopics / topics.length) * 100;

      status.value = DashboardStatus.loaded;
    } catch (e) {
      errorMessage.value = AppFailure.from(e).friendlyMessage;
      status.value = DashboardStatus.error;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    Get.offAllNamed(Routes.login);
  }
}
