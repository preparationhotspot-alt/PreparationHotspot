import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

/// §27 Profile & More -- reuses [DashboardController]'s already-loaded
/// user/exam data rather than fetching it again. Menu items that don't
/// have a real screen yet (Phases 6-8) say so honestly instead of linking
/// nowhere.
class ProfileTabBody extends GetView<DashboardController> {
  const ProfileTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        switch (controller.status.value) {
          case DashboardStatus.loading:
            return const AppLoadingView(message: 'Loading your profile...');
          case DashboardStatus.error:
            return AppErrorView(
              message: controller.errorMessage.value ?? 'Something went wrong.',
              onRetry: controller.load,
            );
          case DashboardStatus.loaded:
            return _ProfileBody(controller: controller);
        }
      }),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final DashboardController controller;
  const _ProfileBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (user?.fullName.isNotEmpty ?? false) ? user!.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? '', style: Theme.of(context).textTheme.titleLarge),
                      Text(user?.email ?? '',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      if (controller.examName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${controller.examName}'
                            '${user?.targetExamYear != null ? " · ${user!.targetExamYear}" : ""}',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _MenuTile(
              icon: Icons.map_outlined,
              label: 'My Study Plan',
              onTap: () => Get.toNamed(Routes.personalizedPlan),
            ),
            _MenuTile(
              icon: Icons.fact_check_outlined,
              label: 'My Tests',
              onTap: () => AppDialogs.info(
                'Test history will show up here once Mock Tests are live.',
                title: 'Coming Soon',
              ),
            ),
            _MenuTile(
              icon: Icons.bookmark_outline,
              label: 'Bookmarks',
              onTap: () => AppDialogs.info(
                'Bookmarking questions, topics, and notes is coming soon.',
                title: 'Coming Soon',
              ),
            ),
            _MenuTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () => AppDialogs.info(
                'Push notification preferences are coming soon.',
                title: 'Coming Soon',
              ),
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => AppDialogs.info(
                'Account settings are coming soon.',
                title: 'Coming Soon',
              ),
            ),
            _MenuTile(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              onTap: () => AppDialogs.info(
                'Reach us soon via in-app support -- coming soon.',
                title: 'Coming Soon',
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.logout_rounded,
              label: 'Logout',
              color: AppColors.error,
              onTap: controller.signOut,
            ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
