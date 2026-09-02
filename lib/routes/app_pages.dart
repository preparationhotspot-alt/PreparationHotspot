import 'package:get/get.dart';

import '../modules/assessment/bindings/assessment_binding.dart';
import '../modules/assessment/views/analysis_loading_view.dart';
import '../modules/assessment/views/answer_review_view.dart';
import '../modules/assessment/views/assessment_instructions_view.dart';
import '../modules/assessment/views/assessment_intro_view.dart';
import '../modules/assessment/views/assessment_question_view.dart';
import '../modules/assessment/views/assessment_result_view.dart';
import '../modules/assessment/views/strong_weak_areas_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/auth/views/welcome_view.dart';
import '../modules/exam/bindings/exam_binding.dart';
import '../modules/exam/views/exam_selection_view.dart';
import '../modules/exam/views/student_profile_view.dart';
import '../modules/main/bindings/main_shell_binding.dart';
import '../modules/main/views/main_shell_view.dart';
import '../modules/study_plan/bindings/personalized_plan_binding.dart';
import '../modules/study_plan/views/personalized_plan_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(name: Routes.splash, page: () => const SplashView()),
    GetPage(name: Routes.welcome, page: () => const WelcomeView()),
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.examSelection,
      page: () => const ExamSelectionView(),
      binding: ExamBinding(),
    ),
    GetPage(
      name: Routes.studentProfile,
      page: () => const StudentProfileView(),
      binding: ExamBinding(),
    ),
    GetPage(
      name: Routes.assessmentIntro,
      page: () => const AssessmentIntroView(),
      binding: AssessmentBinding(),
    ),
    GetPage(
      name: Routes.assessmentInstructions,
      page: () => const AssessmentInstructionsView(),
      binding: AssessmentBinding(),
    ),
    GetPage(
      name: Routes.assessmentQuestion,
      page: () => const AssessmentQuestionView(),
      binding: AssessmentBinding(),
    ),
    GetPage(
      name: Routes.analysisLoading,
      page: () => const AnalysisLoadingView(),
      binding: AssessmentBinding(),
    ),
    GetPage(
      name: Routes.assessmentResult,
      page: () => const AssessmentResultView(),
      binding: AssessmentBinding(),
    ),
    GetPage(
      name: Routes.strongWeakAreas,
      page: () => const StrongWeakAreasView(),
      binding: AssessmentBinding(),
    ),
    GetPage(
      name: Routes.answerReview,
      page: () => const AnswerReviewView(),
      binding: AssessmentBinding(),
    ),
    GetPage(
      name: Routes.personalizedPlan,
      page: () => const PersonalizedPlanView(),
      binding: PersonalizedPlanBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const MainShellView(),
      binding: MainShellBinding(),
    ),
  ];
}
