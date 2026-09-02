import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors `study_plans/{planId}/items/{itemId}` (§16) -- server-computed
/// only by `generateStudyPlan`, purely rule-based on `user_performance`.
class StudyPlanItemModel {
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final String chapterName;
  final String topicId;
  final String topicName;
  final String priority;
  final String reason;
  final double accuracy;
  final int recommendedQuestions;
  final String recommendedDifficulty;
  final String recommendedAction;
  final String status;

  const StudyPlanItemModel({
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.chapterName,
    required this.topicId,
    required this.topicName,
    required this.priority,
    required this.reason,
    required this.accuracy,
    required this.recommendedQuestions,
    required this.recommendedDifficulty,
    required this.recommendedAction,
    required this.status,
  });

  factory StudyPlanItemModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return StudyPlanItemModel(
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      chapterId: data['chapterId'] ?? '',
      chapterName: data['chapterName'] ?? '',
      topicId: data['topicId'] ?? '',
      topicName: data['topicName'] ?? '',
      priority: data['priority'] ?? 'low',
      reason: data['reason'] ?? '',
      accuracy: (data['accuracy'] ?? 0).toDouble(),
      recommendedQuestions: data['recommendedQuestions'] ?? 0,
      recommendedDifficulty: data['recommendedDifficulty'] ?? 'medium',
      recommendedAction: data['recommendedAction'] ?? 'practice',
      status: data['status'] ?? 'pending',
    );
  }

  bool get isHighPriority => priority == 'high';

  String get actionLabel {
    switch (recommendedAction) {
      case 'learning_practice':
        return 'Continue Learning';
      case 'practice':
        return 'Practice Recommended';
      case 'revision':
        return 'Revision Recommended';
      default:
        return 'Review';
    }
  }
}

/// Mirrors `study_plans/{planId}` (§16).
class StudyPlanModel {
  final String id;
  final String userId;
  final String examId;
  final String title;
  final String description;
  final String priority;
  final String status;
  final List<StudyPlanItemModel> items;

  const StudyPlanModel({
    required this.id,
    required this.userId,
    required this.examId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.items = const [],
  });

  factory StudyPlanModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    List<StudyPlanItemModel> items = const [],
  }) {
    final data = doc.data()!;
    return StudyPlanModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      examId: data['examId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      priority: data['priority'] ?? 'low',
      status: data['status'] ?? 'active',
      items: items,
    );
  }
}
