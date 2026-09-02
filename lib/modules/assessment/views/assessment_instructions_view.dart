import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../routes/app_routes.dart';
import '../controllers/assessment_controller.dart';

class AssessmentInstructionsView extends GetView<AssessmentController> {
  const AssessmentInstructionsView({super.key});

  static const _rules = [
    '30 questions across all subjects for your exam.',
    'Duration: 30 minutes, with a visible countdown timer.',
    'Use the question palette to jump between questions.',
    'You can change your answer any time before submitting.',
    'The test auto-submits when time runs out.',
    'Your results and a personalized plan are ready right after.',
  ];

  @override
  Widget build(BuildContext context) {
    controller.loadAssessment();
    return Scaffold(
      appBar: AppBar(title: const Text('Instructions')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  for (final rule in _rules)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Text(rule)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                switch (controller.loadStatus.value) {
                  case AssessmentLoadStatus.loading:
                    return const AppLoadingView(message: 'Preparing your assessment...');
                  case AssessmentLoadStatus.error:
                    return AppErrorView(
                      message: controller.errorMessage.value ?? 'Something went wrong.',
                      onRetry: controller.loadAssessment,
                    );
                  case AssessmentLoadStatus.ready:
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.startTimer();
                          Get.offNamed(Routes.assessmentQuestion);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Begin Assessment'),
                        ),
                      ),
                    );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
