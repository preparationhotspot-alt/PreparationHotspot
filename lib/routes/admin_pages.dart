import 'package:get/get.dart';

import '../modules/admin/auth/views/admin_login_view.dart';
import '../modules/admin/dashboard/controllers/admin_dashboard_controller.dart';
import '../modules/admin/dashboard/views/admin_dashboard_view.dart';
import '../modules/admin/exams/controllers/admin_exam_controller.dart';
import '../modules/admin/exams/views/admin_exam_view.dart';
import '../modules/admin/mock_tests/controllers/admin_mock_test_controller.dart';
import '../modules/admin/mock_tests/views/admin_mock_test_view.dart';
import '../modules/admin/notes/controllers/admin_note_controller.dart';
import '../modules/admin/notes/views/admin_note_view.dart';
import '../modules/admin/questions/controllers/admin_question_controller.dart';
import '../modules/admin/questions/views/admin_question_view.dart';
import '../modules/admin/shell/views/admin_shell.dart';
import '../modules/admin/students/controllers/admin_student_controller.dart';
import '../modules/admin/students/views/admin_student_view.dart';
import 'admin_routes.dart';

class AdminPages {
  AdminPages._();

  static const initial = AdminRoutes.login;

  static final routes = [
    GetPage(name: AdminRoutes.login, page: () => AdminLoginView()),
    GetPage(
      name: AdminRoutes.dashboard,
      page: () => AdminShell(
        currentRoute: AdminRoutes.dashboard,
        child: const AdminDashboardView(),
      ),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
      }),
    ),
    GetPage(
      name: AdminRoutes.exams,
      page: () => AdminShell(
        currentRoute: AdminRoutes.exams,
        child: const AdminExamView(),
      ),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminExamController>(() => AdminExamController());
      }),
    ),
    GetPage(
      name: AdminRoutes.questions,
      page: () => AdminShell(
        currentRoute: AdminRoutes.questions,
        child: const AdminQuestionView(),
      ),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminQuestionController>(() => AdminQuestionController());
      }),
    ),
    GetPage(
      name: AdminRoutes.notes,
      page: () => AdminShell(
        currentRoute: AdminRoutes.notes,
        child: const AdminNoteView(),
      ),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminNoteController>(() => AdminNoteController());
      }),
    ),
    GetPage(
      name: AdminRoutes.mockTests,
      page: () => AdminShell(
        currentRoute: AdminRoutes.mockTests,
        child: const AdminMockTestView(),
      ),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminMockTestController>(() => AdminMockTestController());
      }),
    ),
    GetPage(
      name: AdminRoutes.students,
      page: () => AdminShell(
        currentRoute: AdminRoutes.students,
        child: const AdminStudentView(),
      ),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminStudentController>(() => AdminStudentController());
      }),
    ),
  ];
}
