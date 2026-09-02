import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/utils/app_failure.dart';

enum AdminDashboardStatus { loading, loaded, error }

/// §32: admin dashboard summary counts. Uses Firestore's `count()`
/// aggregation so this never downloads full collections just to count them
/// (§52) -- more charts/metrics are added as their underlying modules land.
class AdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore;
  AdminDashboardController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final status = AdminDashboardStatus.loading.obs;
  final errorMessage = RxnString();

  int totalStudents = 0;
  int totalExams = 0;
  int publishedExams = 0;
  int totalQuestions = 0;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      status.value = AdminDashboardStatus.loading;

      final results = await Future.wait([
        _firestore.collection(FirestorePaths.users).count().get(),
        _firestore.collection(FirestorePaths.exams).count().get(),
        _firestore
            .collection(FirestorePaths.exams)
            .where('status', isEqualTo: 'published')
            .count()
            .get(),
        _firestore.collection(FirestorePaths.questions).count().get(),
      ]);

      totalStudents = results[0].count ?? 0;
      totalExams = results[1].count ?? 0;
      publishedExams = results[2].count ?? 0;
      totalQuestions = results[3].count ?? 0;

      status.value = AdminDashboardStatus.loaded;
    } catch (e) {
      errorMessage.value = AppFailure.from(e).friendlyMessage;
      status.value = AdminDashboardStatus.error;
    }
  }
}
