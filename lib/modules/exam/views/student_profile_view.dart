import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'package:get/get.dart';
import '../controllers/student_profile_controller.dart';

class StudentProfileView extends GetView<StudentProfileController> {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(4, (i) => currentYear + i);

    return Scaffold(
      appBar: AppBar(title: const Text('Tell Us About Yourself')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Academic Level', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Obx(() => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: controller.academicLevels.map((level) {
                      final selected = controller.selectedAcademicLevel.value == level;
                      return ChoiceChip(
                        label: Text(level),
                        selected: selected,
                        onSelected: (_) => controller.selectAcademicLevel(level),
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: selected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 32),
              Text('Target Exam Year', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Obx(() => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: years.map((year) {
                      final selected = controller.targetExamYear.value == year;
                      return ChoiceChip(
                        label: Text('$year'),
                        selected: selected,
                        onSelected: (_) => controller.selectTargetYear(year),
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: selected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 8),
              Obx(() {
                final error = controller.errorMessage.value;
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(error, style: const TextStyle(color: AppColors.error)),
                );
              }),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton(
                    onPressed: controller.isSubmitting.value ? null : controller.submit,
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
            ],
          ),
        ),
      ),
    );
  }
}
