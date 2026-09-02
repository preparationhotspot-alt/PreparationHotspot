import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors a `mock_tests/{testId}` document (§25/§39).
class MockTestModel {
  final String id;
  final String name;
  final String examId;
  final String testType;
  final int durationMinutes;
  final String instructions;
  final String status;
  final List<String> questionIds;

  const MockTestModel({
    required this.id,
    required this.name,
    required this.examId,
    required this.testType,
    required this.durationMinutes,
    required this.instructions,
    required this.status,
    this.questionIds = const [],
  });

  int get totalQuestions => questionIds.length;

  factory MockTestModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MockTestModel(
      id: doc.id,
      name: data['name'] ?? '',
      examId: data['examId'] ?? '',
      testType: data['testType'] ?? 'full_mock',
      durationMinutes: data['durationMinutes'] ?? 60,
      instructions: data['instructions'] ?? '',
      status: data['status'] ?? 'draft',
      questionIds: List<String>.from(data['questionIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'examId': examId,
      'testType': testType,
      'durationMinutes': durationMinutes,
      'instructions': instructions,
      'status': status,
      'questionIds': questionIds,
      'totalQuestions': questionIds.length,
    };
  }
}
