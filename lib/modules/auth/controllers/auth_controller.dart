import 'package:get/get.dart';

import '../../../core/utils/app_failure.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> signInWithEmail(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter your email and password.';
      return;
    }
    await _run(() => _authRepository.signInWithEmail(email, password));
  }

  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (fullName.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill in all fields.';
      return;
    }
    await _run(() => _authRepository.signUpWithEmail(
          fullName: fullName,
          email: email,
          password: password,
        ));
  }

  Future<void> signInWithGoogle() async {
    await _run(() => _authRepository.signInWithGoogle());
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    Get.offAllNamed(Routes.login);
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await action();
      await _routeAfterAuth();
    } catch (e) {
      errorMessage.value = AppFailure.from(e).friendlyMessage;
    } finally {
      isLoading.value = false;
    }
  }

  /// Auth flow per spec §5/§56: after login, route to onboarding (exam
  /// selection), the diagnostic assessment (if onboarded but never
  /// assessed), or straight to Home.
  Future<void> _routeAfterAuth() async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null) return;
    final profile = await _authRepository.fetchUserProfile(uid);
    if (profile == null || !profile.onboardingCompleted) {
      Get.offAllNamed(Routes.examSelection);
    } else if (!profile.assessmentCompleted) {
      Get.offAllNamed(Routes.assessmentIntro);
    } else {
      Get.offAllNamed(Routes.home);
    }
  }
}
