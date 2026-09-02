import 'dart:async';

import 'package:get/get.dart';

import '../../../core/utils/app_failure.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/user_performance_model.dart';
import '../../../data/repositories/assessment_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/performance_repository.dart';
import '../../../routes/app_routes.dart';

enum AssessmentLoadStatus { loading, ready, error }

/// Drives the full diagnostic assessment flow (§9-§15): intro →
/// instructions → 30-question runner (timer, navigation, palette) →
/// submission → analysis → result → strong/weak areas. Scoring itself
/// always happens server-side via [AssessmentRepository] (§30).
class AssessmentController extends GetxController {
  final AssessmentRepository _assessmentRepository;
  final PerformanceRepository _performanceRepository;
  final AuthRepository _authRepository;

  AssessmentController({
    AssessmentRepository? assessmentRepository,
    PerformanceRepository? performanceRepository,
    AuthRepository? authRepository,
  })  : _assessmentRepository = assessmentRepository ?? AssessmentRepository(),
        _performanceRepository = performanceRepository ?? PerformanceRepository(),
        _authRepository = authRepository ?? AuthRepository();

  final loadStatus = AssessmentLoadStatus.loading.obs;
  final errorMessage = RxnString();

  final questions = <QuestionModel>[].obs;
  final currentIndex = 0.obs;
  final answers = <String, dynamic>{}.obs;
  final visited = <String>{}.obs;

  final remainingSeconds = 0.obs;
  Timer? _timer;
  DateTime? _questionEnteredAt;
  final _timeTakenSeconds = <String, int>{};

  final isSubmitting = false.obs;
  String? _attemptId;
  String? _examId;

  SubmittedAssessmentResult? result;
  List<UserPerformanceModel> strongTopics = [];
  List<UserPerformanceModel> averageTopics = [];
  List<UserPerformanceModel> weakTopics = [];
  List<UserPerformanceModel> insufficientDataTopics = [];

  QuestionModel get currentQuestion => questions[currentIndex.value];
  int get totalQuestions => questions.length;
  int get answeredCount => answers.length;

  bool _loadStarted = false;

  Future<void> loadAssessment() async {
    if (_loadStarted) return;
    _loadStarted = true;
    try {
      loadStatus.value = AssessmentLoadStatus.loading;
      final uid = _authRepository.currentUser!.uid;
      final profile = await _authRepository.fetchUserProfile(uid);
      final examId = profile?.selectedExamId;
      if (examId == null) {
        errorMessage.value = 'Please select an exam first.';
        loadStatus.value = AssessmentLoadStatus.error;
        _loadStarted = false;
        return;
      }
      _examId = examId;
      final generated = await _assessmentRepository.generateAssessment(examId);
      _attemptId = generated.attemptId;
      questions.assignAll(generated.questions);
      remainingSeconds.value = generated.durationMinutes * 60;
      loadStatus.value = AssessmentLoadStatus.ready;
    } catch (e) {
      errorMessage.value = AppFailure.from(e).friendlyMessage;
      loadStatus.value = AssessmentLoadStatus.error;
      _loadStarted = false;
    }
  }

  void startTimer() {
    _questionEnteredAt = DateTime.now();
    visited.add(currentQuestion.questionId);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds.value <= 1) {
        remainingSeconds.value = 0;
        _timer?.cancel();
        submitAssessment();
      } else {
        remainingSeconds.value--;
      }
    });
  }

  void _bankTimeForCurrentQuestion() {
    final enteredAt = _questionEnteredAt;
    if (enteredAt == null) return;
    final elapsed = DateTime.now().difference(enteredAt).inSeconds;
    final questionId = currentQuestion.questionId;
    _timeTakenSeconds[questionId] = (_timeTakenSeconds[questionId] ?? 0) + elapsed;
    _questionEnteredAt = DateTime.now();
  }

  void selectSingleAnswer(String optionKey) {
    answers[currentQuestion.questionId] = optionKey;
  }

  void toggleMultipleAnswer(String optionKey) {
    final questionId = currentQuestion.questionId;
    final current = List<String>.from(answers[questionId] as List? ?? []);
    if (current.contains(optionKey)) {
      current.remove(optionKey);
    } else {
      current.add(optionKey);
    }
    answers[questionId] = current;
  }

  void setTextAnswer(String value) {
    answers[currentQuestion.questionId] = value;
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= questions.length) return;
    _bankTimeForCurrentQuestion();
    currentIndex.value = index;
    visited.add(currentQuestion.questionId);
  }

  void nextQuestion() => goToQuestion(currentIndex.value + 1);
  void previousQuestion() => goToQuestion(currentIndex.value - 1);

  bool isAnswered(String questionId) => answers.containsKey(questionId);
  bool get isLastQuestion => currentIndex.value == questions.length - 1;

  Future<void> submitAssessment() async {
    if (isSubmitting.value) return;
    _timer?.cancel();
    _bankTimeForCurrentQuestion();

    try {
      isSubmitting.value = true;
      final payload = questions.map((q) {
        final selected = answers[q.questionId];
        return {
          'questionId': q.questionId,
          'selectedAnswer': selected,
          'timeTaken': _timeTakenSeconds[q.questionId] ?? 0,
        };
      }).toList();

      Get.offNamed(Routes.analysisLoading);

      result = await _assessmentRepository.submitAssessment(
        attemptId: _attemptId!,
        answers: payload,
      );

      await _loadPerformanceBreakdown();
      Get.offNamed(Routes.strongWeakAreas);
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage, title: 'Submission failed');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _loadPerformanceBreakdown() async {
    final uid = _authRepository.currentUser!.uid;
    final topics = await _performanceRepository.fetchTopicPerformance(
      userId: uid,
      examId: _examId!,
    );
    strongTopics = topics.where((t) => t.isStrong).toList();
    averageTopics = topics.where((t) => t.isAverage).toList();
    weakTopics = topics.where((t) => t.isWeak).toList();
    insufficientDataTopics = topics.where((t) => t.isInsufficientData).toList();
  }

  void goToStrongWeakAreas() => Get.offNamed(Routes.strongWeakAreas);

  /// §56: Strong/Weak Areas -> Personalized Plan, not straight to Home --
  /// the plan is already generated server-side by this point.
  void goToPersonalizedPlan() {
    Get.offAllNamed(Routes.personalizedPlan);
    Get.delete<AssessmentController>();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
