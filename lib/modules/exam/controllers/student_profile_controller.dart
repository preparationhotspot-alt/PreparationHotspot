import 'package:get/get.dart';

import '../../../core/utils/app_failure.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

/// Collects target exam year + academic level, then marks onboarding
/// complete and routes into the Diagnostic Assessment flow (§9, §56).
class StudentProfileController extends GetxController {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  StudentProfileController({
    UserRepository? userRepository,
    AuthRepository? authRepository,
  })  : _userRepository = userRepository ?? UserRepository(),
        _authRepository = authRepository ?? AuthRepository();

  final academicLevels = const [
    'Class 11',
    'Class 12',
    'Dropper / Repeater',
  ];

  final selectedAcademicLevel = RxnString();
  final targetExamYear = RxnInt();
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  void selectAcademicLevel(String level) => selectedAcademicLevel.value = level;
  void selectTargetYear(int year) => targetExamYear.value = year;

  Future<void> submit() async {
    final uid = _authRepository.currentUser?.uid;
    final level = selectedAcademicLevel.value;
    final year = targetExamYear.value;

    if (uid == null || level == null || year == null) {
      errorMessage.value = 'Please complete all fields.';
      return;
    }

    try {
      isSubmitting.value = true;
      errorMessage.value = null;
      await _userRepository.completeStudentProfile(
        uid,
        targetExamYear: year,
        academicLevel: level,
      );
      Get.offAllNamed(Routes.assessmentIntro);
    } catch (e) {
      errorMessage.value = AppFailure.from(e).friendlyMessage;
    } finally {
      isSubmitting.value = false;
    }
  }
}
