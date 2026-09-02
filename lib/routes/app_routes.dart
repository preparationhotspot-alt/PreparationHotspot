/// Central route name registry. New modules add their route constants
/// here rather than using raw strings inline.
class Routes {
  Routes._();

  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';

  static const examSelection = '/exam-selection';
  static const studentProfile = '/student-profile';

  static const assessmentIntro = '/assessment-intro';
  static const assessmentInstructions = '/assessment-instructions';
  static const assessmentQuestion = '/assessment-question';
  static const analysisLoading = '/analysis-loading';
  static const assessmentResult = '/assessment-result';
  static const strongWeakAreas = '/strong-weak-areas';
  static const answerReview = '/answer-review';
  static const personalizedPlan = '/personalized-plan';

  static const home = '/home';
  static const prepare = '/prepare';
  static const practice = '/practice';
  static const performance = '/performance';
  static const profile = '/profile';
}
