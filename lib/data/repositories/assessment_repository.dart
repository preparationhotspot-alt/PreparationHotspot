import 'package:cloud_functions/cloud_functions.dart';

import '../models/question_model.dart';
import '../models/question_review_model.dart';

class GeneratedAssessment {
  final String attemptId;
  final int durationMinutes;
  final List<QuestionModel> questions;

  const GeneratedAssessment({
    required this.attemptId,
    required this.durationMinutes,
    required this.questions,
  });
}

class SubmittedAssessmentResult {
  final String attemptId;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unanswered;
  final num score;
  final double accuracy;
  final int totalQuestions;
  final List<QuestionReviewModel> reviewAnswers;

  const SubmittedAssessmentResult({
    required this.attemptId,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unanswered,
    required this.score,
    required this.accuracy,
    required this.totalQuestions,
    this.reviewAnswers = const [],
  });
}

/// Talks to the `generateDiagnosticAssessment` / `submitDiagnosticAssessment`
/// Cloud Functions (§29) -- the mobile app never scores itself or reads raw
/// question docs directly (§30).
class AssessmentRepository {
  final FirebaseFunctions _functions;

  AssessmentRepository({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  Future<GeneratedAssessment> generateAssessment(String examId) async {
    final callable = _functions.httpsCallable('generateDiagnosticAssessment');
    final result = await callable.call({'examId': examId});
    final data = Map<String, dynamic>.from(result.data as Map);
    final questions = ((data['questions'] as List?) ?? [])
        .map((q) => QuestionModel.fromMap(Map<String, dynamic>.from(q)))
        .toList();
    return GeneratedAssessment(
      attemptId: data['attemptId'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 30,
      questions: questions,
    );
  }

  Future<SubmittedAssessmentResult> submitAssessment({
    required String attemptId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final callable = _functions.httpsCallable('submitDiagnosticAssessment');
    final result = await callable.call({
      'attemptId': attemptId,
      'answers': answers,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    final reviewAnswers = ((data['reviewAnswers'] as List?) ?? [])
        .map((r) => QuestionReviewModel.fromMap(Map<String, dynamic>.from(r)))
        .toList();
    return SubmittedAssessmentResult(
      attemptId: data['attemptId'] ?? attemptId,
      correctAnswers: data['correctAnswers'] ?? 0,
      incorrectAnswers: data['incorrectAnswers'] ?? 0,
      unanswered: data['unanswered'] ?? 0,
      score: data['score'] ?? 0,
      accuracy: (data['accuracy'] ?? 0).toDouble(),
      totalQuestions: data['totalQuestions'] ?? 0,
      reviewAnswers: reviewAnswers,
    );
  }
}
