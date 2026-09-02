import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

/// §27/§56: "Assessment Introduction" -- explains the diagnostic assessment
/// before the student opts in, per the product's onboarding flow.
class AssessmentIntroView extends StatelessWidget {
  const AssessmentIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.fact_check_outlined, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              Text('Let\'s find your preparation level',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              const Text(
                'You\'ll take a short 30-question diagnostic assessment '
                'covering all subjects. This helps us understand your '
                'strengths and weaknesses so we can build a preparation '
                'plan made just for you.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.assessmentInstructions),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Start Diagnostic Assessment'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
