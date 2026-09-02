import 'package:cloud_firestore/cloud_firestore.dart';

/// One graded answer inside a `diagnostic_attempts/{attemptId}` document
/// (§11). Written only by Cloud Functions after server-side grading.
class GradedAnswerModel {
  final String questionId;
  final dynamic selectedAnswer;
  final dynamic correctAnswer;
  final bool isCorrect;
  final bool isAnswered;
  final int timeTaken;
  final num marksAwarded;
  final String subjectId;
  final String chapterId;
  final String topicId;

  const GradedAnswerModel({
    required this.questionId,
    this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.isAnswered,
    required this.timeTaken,
    required this.marksAwarded,
    required this.subjectId,
    required this.chapterId,
    required this.topicId,
  });

  factory GradedAnswerModel.fromMap(Map<String, dynamic> map) {
    return GradedAnswerModel(
      questionId: map['questionId'] ?? '',
      selectedAnswer: map['selectedAnswer'],
      correctAnswer: map['correctAnswer'],
      isCorrect: map['isCorrect'] ?? false,
      isAnswered: map['isAnswered'] ?? false,
      timeTaken: map['timeTaken'] ?? 0,
      marksAwarded: map['marksAwarded'] ?? 0,
      subjectId: map['subjectId'] ?? '',
      chapterId: map['chapterId'] ?? '',
      topicId: map['topicId'] ?? '',
    );
  }
}

/// Mirrors a `diagnostic_attempts/{attemptId}` document (§11).
class DiagnosticAttemptModel {
  final String attemptId;
  final String userId;
  final String examId;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final int duration;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unanswered;
  final num score;
  final double accuracy;
  final String status;
  final List<GradedAnswerModel> answers;

  const DiagnosticAttemptModel({
    required this.attemptId,
    required this.userId,
    required this.examId,
    this.startedAt,
    this.submittedAt,
    required this.duration,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unanswered,
    required this.score,
    required this.accuracy,
    required this.status,
    this.answers = const [],
  });

  factory DiagnosticAttemptModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;
    return DiagnosticAttemptModel(
      attemptId: doc.id,
      userId: data['userId'] ?? '',
      examId: data['examId'] ?? '',
      startedAt: toDate(data['startedAt']),
      submittedAt: toDate(data['submittedAt']),
      duration: data['duration'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      incorrectAnswers: data['incorrectAnswers'] ?? 0,
      unanswered: data['unanswered'] ?? 0,
      score: data['score'] ?? 0,
      accuracy: (data['accuracy'] ?? 0).toDouble(),
      status: data['status'] ?? 'in_progress',
      answers: ((data['answers'] as List?) ?? [])
          .map((a) => GradedAnswerModel.fromMap(Map<String, dynamic>.from(a)))
          .toList(),
    );
  }
}
