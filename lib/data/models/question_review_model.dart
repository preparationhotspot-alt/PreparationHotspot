/// Per-question review data returned by `submitDiagnosticAssessment` after
/// grading (§23) -- correct answers/explanations are only ever revealed
/// post-submission, never before (§30).
class QuestionReviewModel {
  final String questionId;
  final String questionText;
  final String? questionImage;
  final List<Map<String, dynamic>> options;
  final dynamic selectedAnswer;
  final dynamic correctAnswer;
  final bool isCorrect;
  final bool isAnswered;
  final String explanation;
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final String chapterName;
  final String topicId;
  final String topicName;

  const QuestionReviewModel({
    required this.questionId,
    required this.questionText,
    this.questionImage,
    this.options = const [],
    this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.isAnswered,
    required this.explanation,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.chapterName,
    required this.topicId,
    required this.topicName,
  });

  factory QuestionReviewModel.fromMap(Map<String, dynamic> map) {
    return QuestionReviewModel(
      questionId: map['questionId'] ?? '',
      questionText: map['questionText'] ?? '',
      questionImage: map['questionImage'],
      options: ((map['options'] as List?) ?? [])
          .map((o) => Map<String, dynamic>.from(o))
          .toList(),
      selectedAnswer: map['selectedAnswer'],
      correctAnswer: map['correctAnswer'],
      isCorrect: map['isCorrect'] ?? false,
      isAnswered: map['isAnswered'] ?? false,
      explanation: map['explanation'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      chapterId: map['chapterId'] ?? '',
      chapterName: map['chapterName'] ?? '',
      topicId: map['topicId'] ?? '',
      topicName: map['topicName'] ?? '',
    );
  }

  String optionText(String key) {
    final match = options.firstWhere(
      (o) => o['key'] == key,
      orElse: () => const {},
    );
    return match['text'] ?? key;
  }
}
