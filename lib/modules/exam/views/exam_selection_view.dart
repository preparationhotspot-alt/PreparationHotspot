import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_state_views.dart';
import '../controllers/exam_selection_controller.dart';

class ExamSelectionView extends GetView<ExamSelectionController> {
  const ExamSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Exam')),
      body: SafeArea(
        child: Obx(() {
          switch (controller.status.value) {
            case ExamSelectionStatus.loading:
              return const AppLoadingView(message: 'Loading exams...');
            case ExamSelectionStatus.error:
              return AppErrorView(
                message: controller.errorMessage.value ?? 'Something went wrong.',
                onRetry: controller.loadExams,
              );
            case ExamSelectionStatus.empty:
              return const AppEmptyView(
                title: 'No exams available yet',
                subtitle: 'Please check back soon.',
                icon: Icons.school_outlined,
              );
            case ExamSelectionStatus.loaded:
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.exams.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final exam = controller.exams[index];
                        return Obx(() {
                          final isSelected =
                              controller.selectedExamId.value == exam.id;
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => controller.selectExam(exam.id),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.menu_book_outlined,
                                      color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(exam.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge),
                                        if (exam.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            exam.description,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle,
                                        color: AppColors.primary),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.selectedExamId.value == null ||
                                  controller.isSubmitting.value
                              ? null
                              : controller.confirmSelection,
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Continue'),
                        )),
                  ),
                ],
              );
          }
        }),
      ),
    );
  }
}
