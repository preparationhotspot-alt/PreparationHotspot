import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/mock_test_model.dart';
import '../controllers/admin_mock_test_controller.dart';
import 'mock_test_form_dialog.dart';

class AdminMockTestView extends GetView<AdminMockTestController> {
  const AdminMockTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Mock Tests', style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                ElevatedButton.icon(
                  style: AppTheme.compactButton,
                  onPressed: () => showMockTestFormDialog(controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Test'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.mockTests.isEmpty) {
                  return const Center(child: Text('No mock tests yet. Create one to get started.'));
                }
                return ListView.separated(
                  itemCount: controller.mockTests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _MockTestRow(test: controller.mockTests[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockTestRow extends StatelessWidget {
  final MockTestModel test;
  const _MockTestRow({required this.test});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminMockTestController>();
    final isPublished = test.status == 'published';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.fact_check_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  '${test.examId} · ${test.totalQuestions} questions · ${test.durationMinutes} min',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: isPublished,
            onChanged: (_) => controller.toggleStatus(test),
            activeThumbColor: AppColors.strong,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => showMockTestFormDialog(controller, existing: test),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
            onPressed: () => controller.deleteMockTest(test),
          ),
        ],
      ),
    );
  }
}
