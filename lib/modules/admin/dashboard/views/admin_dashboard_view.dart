import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'package:get/get.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                switch (controller.status.value) {
                  case AdminDashboardStatus.loading:
                    return const AppLoadingView(message: 'Loading dashboard...');
                  case AdminDashboardStatus.error:
                    return AppErrorView(
                      message: controller.errorMessage.value ?? 'Something went wrong.',
                      onRetry: controller.load,
                    );
                  case AdminDashboardStatus.loaded:
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _StatTile(
                            label: 'Total Students',
                            value: '${controller.totalStudents}',
                            icon: Icons.people_outline),
                        _StatTile(
                            label: 'Total Exams',
                            value: '${controller.totalExams}',
                            icon: Icons.school_outlined),
                        _StatTile(
                            label: 'Published Exams',
                            value: '${controller.publishedExams}',
                            icon: Icons.check_circle_outline),
                        _StatTile(
                            label: 'Total Questions',
                            value: '${controller.totalQuestions}',
                            icon: Icons.quiz_outlined),
                      ],
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

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
