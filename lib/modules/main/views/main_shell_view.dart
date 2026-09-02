import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../dashboard/views/home_tab_body.dart';
import '../../performance/views/performance_tab_body.dart';
import '../../prepare/views/prepare_tab_body.dart';
import '../../practice/views/practice_tab_body.dart';
import '../../profile/views/profile_tab_body.dart';
import '../controllers/main_shell_controller.dart';

/// §27: the 5-tab bottom navigation shell (Home/Prepare/Practice/
/// Performance/Profile) every screen in the mockup's main app experience
/// lives inside. Tab bodies own their own headers/scrolling -- this shell
/// only owns the IndexedStack + bottom nav bar.
class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  static const _tabs = [
    HomeTabBody(),
    PrepareTabBody(),
    PracticeTabBody(),
    PerformanceTabBody(),
    ProfileTabBody(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(index: controller.currentIndex.value, children: _tabs)),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: controller.changeTab,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primaryLight,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Prepare'),
              NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note_rounded), label: 'Practice'),
              NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'Performance'),
              NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          )),
    );
  }
}
