/// Central place for Firestore collection names so paths never get
/// typo'd across repositories.
class FirestorePaths {
  FirestorePaths._();

  static const users = 'users';
  static const exams = 'exams';
  static const subjects = 'subjects';
  static const chapters = 'chapters';
  static const topics = 'topics';
  static const diagnosticConfig = 'diagnostic_config';
  static const questions = 'questions';
  static const notes = 'notes';
  static const diagnosticAttempts = 'diagnostic_attempts';
  static const mockTests = 'mock_tests';
  static const mockAttempts = 'mock_attempts';
  static const practiceSessions = 'practice_sessions';
  static const studyPlans = 'study_plans';
  static const studyPlanItems = 'items';
  static const userPerformance = 'user_performance';
  static const bookmarks = 'bookmarks';
  static const notifications = 'notifications';
  static const reports = 'reports';
  static const settings = 'settings';
}
