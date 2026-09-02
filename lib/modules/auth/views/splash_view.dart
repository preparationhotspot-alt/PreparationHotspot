import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

/// Splash: waits a beat, checks Firebase auth state, and routes per §5:
/// not logged in -> Welcome; logged in -> check onboardingCompleted.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveInitialRoute());
  }

  Future<void> _resolveInitialRoute() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final User? user = _authRepository.currentUser;

    if (user == null) {
      Get.offAllNamed(Routes.welcome);
      return;
    }

    try {
      final profile = await _authRepository.fetchUserProfile(user.uid);
      if (profile == null || !profile.onboardingCompleted) {
        Get.offAllNamed(Routes.examSelection);
      } else if (!profile.assessmentCompleted) {
        Get.offAllNamed(Routes.assessmentIntro);
      } else {
        Get.offAllNamed(Routes.home);
      }
    } catch (_) {
      Get.offAllNamed(Routes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_rounded, color: Colors.white, size: 56),
              SizedBox(height: 16),
              Text(
                AppStrings.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 8),
              Text(
                AppStrings.tagline,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
