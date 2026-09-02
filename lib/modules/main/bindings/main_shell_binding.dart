import 'package:get/get.dart';

import '../../dashboard/controllers/dashboard_controller.dart';
import '../../performance/controllers/performance_overview_controller.dart';
import '../controllers/main_shell_controller.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainShellController>(() => MainShellController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<PerformanceOverviewController>(() => PerformanceOverviewController());
  }
}
