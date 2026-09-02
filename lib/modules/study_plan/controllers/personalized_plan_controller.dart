import 'package:get/get.dart';

import '../../../core/utils/app_failure.dart';
import '../../../data/models/study_plan_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/study_plan_repository.dart';
import '../../../routes/app_routes.dart';

enum PersonalizedPlanStatus { loading, loaded, empty, error }

/// §16/§56: full personalized study plan -- 100% server-computed by
/// `generateStudyPlan` (§17), grouped by priority since the plan has no
/// week-by-week schedule (that would need a target-date model this app
/// doesn't have yet).
class PersonalizedPlanController extends GetxController {
  final StudyPlanRepository _studyPlanRepository;
  final AuthRepository _authRepository;

  PersonalizedPlanController({
    StudyPlanRepository? studyPlanRepository,
    AuthRepository? authRepository,
  })  : _studyPlanRepository = studyPlanRepository ?? StudyPlanRepository(),
        _authRepository = authRepository ?? AuthRepository();

  final status = PersonalizedPlanStatus.loading.obs;
  final errorMessage = RxnString();
  StudyPlanModel? plan;

  List<StudyPlanItemModel> get highPriority =>
      (plan?.items ?? []).where((i) => i.priority == 'high').toList();
  List<StudyPlanItemModel> get mediumPriority =>
      (plan?.items ?? []).where((i) => i.priority == 'medium').toList();
  List<StudyPlanItemModel> get lowPriority =>
      (plan?.items ?? []).where((i) => i.priority == 'low').toList();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      status.value = PersonalizedPlanStatus.loading;
      final uid = _authRepository.currentUser!.uid;
      final profile = await _authRepository.fetchUserProfile(uid);
      final examId = profile?.selectedExamId;
      if (examId == null) {
        status.value = PersonalizedPlanStatus.empty;
        return;
      }
      plan = await _studyPlanRepository.fetchPlan(userId: uid, examId: examId);
      status.value =
          (plan == null || plan!.items.isEmpty)
              ? PersonalizedPlanStatus.empty
              : PersonalizedPlanStatus.loaded;
    } catch (e) {
      errorMessage.value = AppFailure.from(e).friendlyMessage;
      status.value = PersonalizedPlanStatus.error;
    }
  }

  void startLearning() => Get.offAllNamed(Routes.home);
}
