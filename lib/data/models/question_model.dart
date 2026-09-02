/// Sanitized question shape returned by `generateDiagnosticAssessment`
/// (§10). Correct answers/explanations are never sent to the client before
/// submission -- grading happens server-side (§30).
class QuestionOptionModel {
  final String key;
  final String text;

  const QuestionOptionModel({required this.key, required this.text});

  factory QuestionOptionModel.fromMap(Map<String, dynamic> map) {
    return QuestionOptionModel(key: map['key'] ?? '', text: map['text'] ?? '');
  }
}

class QuestionModel {
  final String questionId;
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
  final List<QuestionOptionModel> options;
  final num marks;
  final num negativeMarks;

  const QuestionModel({
    required this.questionId,
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
    required this.marks,
    required this.negativeMarks,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      questionId: map['questionId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      chapterId: map['chapterId'] ?? '',
      chapterName: map['chapterName'] ?? '',
      topicId: map['topicId'] ?? '',
      topicName: map['topicName'] ?? '',
      questionType: map['questionType'] ?? 'single_choice',
      difficulty: map['difficulty'] ?? 'medium',
      questionText: map['questionText'] ?? '',
      questionImage: map['questionImage'],
      options: ((map['options'] as List?) ?? [])
          .map((o) => QuestionOptionModel.fromMap(Map<String, dynamic>.from(o)))
          .toList(),
      marks: map['marks'] ?? 4,
      negativeMarks: map['negativeMarks'] ?? 1,
    );
  }

  bool get isMultipleChoice => questionType == 'multiple_choice';
  bool get isTextEntry => questionType == 'numerical' || questionType == 'integer';
}
