import 'package:cloud_firestore/cloud_firestore.dart';

/// Full `questions/{questionId}` document (§10/§36) -- unlike
/// [QuestionModel] (the sanitized shape sent to students), this carries
/// the correct answer/explanation because only admins ever read it
/// directly (firestore.rules: `questions` is admin-only).
class AdminQuestionModel {
  final String id;
  final String examId;
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final String chapterName;
  final String topicId;
  final String topicName;
  final String questionType;
  final String difficulty;
  final String questionText;
  final String? questionImage;
  final List<Map<String, String>> options;
  final dynamic correctAnswer;
  final String explanation;
  final num marks;
  final num negativeMarks;
  final String source;
  final int? year;
  final String status;

  const AdminQuestionModel({
    required this.id,
    required this.examId,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.chapterName,
    required this.topicId,
    required this.topicName,
    required this.questionType,
    required this.difficulty,
    required this.questionText,
    this.questionImage,
    this.options = const [],
    required this.correctAnswer,
    required this.explanation,
    required this.marks,
    required this.negativeMarks,
    required this.source,
    this.year,
    required this.status,
  });

  factory AdminQuestionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AdminQuestionModel(
      id: doc.id,
      examId: data['examId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      chapterId: data['chapterId'] ?? '',
      chapterName: data['chapterName'] ?? '',
      topicId: data['topicId'] ?? '',
      topicName: data['topicName'] ?? '',
      questionType: data['questionType'] ?? 'single_choice',
      difficulty: data['difficulty'] ?? 'medium',
      questionText: data['questionText'] ?? '',
      questionImage: data['questionImage'],
      options: ((data['options'] as List?) ?? [])
          .map((o) => Map<String, String>.from(o))
          .toList(),
      correctAnswer: data['correctAnswer'],
      explanation: data['explanation'] ?? '',
      marks: data['marks'] ?? 4,
      negativeMarks: data['negativeMarks'] ?? 1,
      source: data['source'] ?? '',
      year: data['year'],
      status: data['status'] ?? 'draft',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'chapterId': chapterId,
      'chapterName': chapterName,
      'topicId': topicId,
      'topicName': topicName,
      'questionType': questionType,
      'difficulty': difficulty,
      'questionText': questionText,
      'questionImage': questionImage,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'marks': marks,
      'negativeMarks': negativeMarks,
      'source': source,
      'year': year,
      'status': status,
    };
  }
}
