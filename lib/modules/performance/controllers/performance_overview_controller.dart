import 'package:get/get.dart';

import '../../../core/utils/app_failure.dart';
import '../../../data/models/user_performance_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/performance_repository.dart';

enum PerformanceOverviewStatus { loading, loaded, empty, error }

/// Standalone "My Performance" screen data source (§26) -- unlike
/// [AssessmentController]'s strong/weak view, this isn't tied to a
/// just-submitted attempt: it's reachable any time from Home and always
/// reflects the student's current cumulative topic performance.
class PerformanceOverviewController extends GetxController {
  final PerformanceRepository _performanceRepository;
  final AuthRepository _authRepository;

  PerformanceOverviewController({
    PerformanceRepository? performanceRepository,
    AuthRepository? authRepository,
  })  : _performanceRepository = performanceRepository ?? PerformanceRepository(),
        _authRepository = authRepository ?? AuthRepository();

  final status = PerformanceOverviewStatus.loading.obs;
  final errorMessage = RxnString();

  List<UserPerformanceModel> strongTopics = [];
  List<UserPerformanceModel> averageTopics = [];
  List<UserPerformanceModel> weakTopics = [];
  List<UserPerformanceModel> insufficientDataTopics = [];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      status.value = PerformanceOverviewStatus.loading;
      final uid = _authRepository.currentUser!.uid;
      final profile = await _authRepository.fetchUserProfile(uid);
      final examId = profile?.selectedExamId;
      if (examId == null) {
        status.value = PerformanceOverviewStatus.empty;
        return;
      }

      final topics = await _performanceRepository.fetchTopicPerformance(
        userId: uid,
        examId: examId,
      );

      strongTopics = topics.where((t) => t.isStrong).toList();
      averageTopics = topics.where((t) => t.isAverage).toList();
      weakTopics = topics.where((t) => t.isWeak).toList();
      insufficientDataTopics = topics.where((t) => t.isInsufficientData).toList();

      status.value = topics.isEmpty
          ? PerformanceOverviewStatus.empty
          : PerformanceOverviewStatus.loaded;
    } catch (e) {
      errorMessage.value = AppFailure.from(e).friendlyMessage;
      status.value = PerformanceOverviewStatus.error;
    }
  }
}
