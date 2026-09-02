import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../routes/admin_routes.dart';
import '../../auth/controllers/admin_auth_controller.dart';

/// Persistent side-nav shell wrapping every admin screen (§31). More nav
/// entries are added here as each admin module lands -- unbuilt ones are
/// intentionally omitted rather than linking to dead screens.
class AdminShell extends StatelessWidget {
  final String currentRoute;
  final Widget child;
  const AdminShell({super.key, required this.currentRoute, required this.child});

  static const _navItems = [
    _NavItem(route: AdminRoutes.dashboard, icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(route: AdminRoutes.exams, icon: Icons.school_outlined, label: 'Exams'),
    _NavItem(route: AdminRoutes.questions, icon: Icons.quiz_outlined, label: 'Question Bank'),
    _NavItem(route: AdminRoutes.notes, icon: Icons.article_outlined, label: 'Notes'),
    _NavItem(
        route: AdminRoutes.mockTests, icon: Icons.fact_check_outlined, label: 'Mock Tests'),
    _NavItem(route: AdminRoutes.students, icon: Icons.people_outline, label: 'Students'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isWide ? null : Drawer(child: _SideNav(currentRoute: currentRoute)),
      appBar: isWide
          ? null
          : AppBar(title: const Text('Admin'), backgroundColor: AppColors.surface),
      body: Row(
        children: [
          if (isWide)
            SizedBox(width: 240, child: _SideNav(currentRoute: currentRoute)),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavItem {
  final String route;
  final IconData icon;
  final String label;
  const _NavItem({required this.route, required this.icon, required this.label});
}

class _SideNav extends StatelessWidget {
  final String currentRoute;
  const _SideNav({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('PreparationHotspot',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            for (final item in AdminShell._navItems)
              ListTile(
                leading: Icon(item.icon,
                    color: currentRoute == item.route
                        ? AppColors.primary
                        : AppColors.textSecondary),
                title: Text(item.label,
                    style: TextStyle(
                      color: currentRoute == item.route
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight:
                          currentRoute == item.route ? FontWeight.w700 : FontWeight.normal,
                    )),
                selected: currentRoute == item.route,
                selectedTileColor: AppColors.primaryLight,
                onTap: () {
                  if (currentRoute != item.route) Get.offAllNamed(item.route);
                },
              ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
              title: const Text('Sign Out'),
              onTap: () => Get.find<AdminAuthController>().signOut(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
