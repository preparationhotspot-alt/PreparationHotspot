import 'package:get/get.dart';

import '../../../../core/utils/app_failure.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../routes/admin_routes.dart';

/// Gates the entire admin panel behind the `admin` custom claim (§30/§31) --
/// granted only via `functions/scripts/set-admin-claim.js`, never
/// self-serve. A successfully authenticated non-admin user is immediately
/// signed out rather than shown any admin UI.
class AdminAuthController extends GetxController {
  final AuthRepository _authRepository;
  AdminAuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> signIn(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter your email and password.';
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await _authRepository.signInWithEmail(email, password);
      await _verifyAdminAndRoute();
    } catch (e) {
      errorMessage.value = AppFailure.from(e).friendlyMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _verifyAdminAndRoute() async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    final tokenResult = await user.getIdTokenResult(true);
    final isAdmin = tokenResult.claims?['admin'] == true;

    if (!isAdmin) {
      await _authRepository.signOut();
      errorMessage.value = 'This account does not have admin access.';
      return;
    }
    Get.offAllNamed(AdminRoutes.dashboard);
  }

  /// Called on app start (persisted session) to skip the login screen if
  /// already signed in with a valid admin claim.
  Future<bool> checkExistingSession() async {
    final user = _authRepository.currentUser;
    if (user == null) return false;
    final tokenResult = await user.getIdTokenResult();
    return tokenResult.claims?['admin'] == true;
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    Get.offAllNamed(AdminRoutes.login);
  }
}
