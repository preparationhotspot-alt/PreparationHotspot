import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors a `user_performance/{docId}` document (§14). One doc per
/// subject, chapter, or topic node -- distinguished by [level] and by which
/// of [chapterId]/[topicId] are non-null. Server-computed only (§30).
class UserPerformanceModel {
  final String userId;
  final String examId;
  final String subjectId;
  final String subjectName;
  final String? chapterId;
  final String? chapterName;
  final String? topicId;
  final String? topicName;
  final String level;
  final int totalQuestions;
  final int attemptedQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unansweredQuestions;
  final double accuracy;
  final double averageTime;
  final String performanceStatus;
  final DateTime? lastAttemptedAt;

  const UserPerformanceModel({
    required this.userId,
    required this.examId,
    required this.subjectId,
    required this.subjectName,
    this.chapterId,
    this.chapterName,
    this.topicId,
    this.topicName,
    required this.level,
    required this.totalQuestions,
    required this.attemptedQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unansweredQuestions,
    required this.accuracy,
    required this.averageTime,
    required this.performanceStatus,
    this.lastAttemptedAt,
  });

  factory UserPerformanceModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserPerformanceModel(
      userId: data['userId'] ?? '',
      examId: data['examId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      chapterId: data['chapterId'],
      chapterName: data['chapterName'],
      topicId: data['topicId'],
      topicName: data['topicName'],
      level: data['level'] ?? 'topic',
      totalQuestions: data['totalQuestions'] ?? 0,
      attemptedQuestions: data['attemptedQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      incorrectAnswers: data['incorrectAnswers'] ?? 0,
      unansweredQuestions: data['unansweredQuestions'] ?? 0,
      accuracy: (data['accuracy'] ?? 0).toDouble(),
      averageTime: (data['averageTime'] ?? 0).toDouble(),
      performanceStatus: data['performanceStatus'] ?? 'insufficient_data',
      lastAttemptedAt: data['lastAttemptedAt'] is Timestamp
          ? (data['lastAttemptedAt'] as Timestamp).toDate()
          : null,
    );
  }

  bool get isStrong => performanceStatus == 'strong';
  bool get isWeak => performanceStatus == 'weak';
  bool get isAverage => performanceStatus == 'average';
  bool get isInsufficientData => performanceStatus == 'insufficient_data';
}
