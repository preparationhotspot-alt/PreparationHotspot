/// Route registry for the admin panel entry point (`main_admin.dart`).
/// Kept separate from the student app's [Routes] since they're entirely
/// different compiled apps (§31).
class AdminRoutes {
  AdminRoutes._();

  static const login = '/login';
  static const dashboard = '/dashboard';
  static const exams = '/exams';
  static const questions = '/questions';
  static const notes = '/notes';
  static const mockTests = '/mock-tests';
  static const students = '/students';
}
