import 'package:csv/csv.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Mirrors `functions/scripts/bulk-import-questions.js` exactly (§37) so
/// the admin-panel CSV import and the CLI script validate identically.
class CsvRowError {
  final int rowNumber;
  final List<String> errors;
  const CsvRowError(this.rowNumber, this.errors);
}

class ParsedCsvResult {
  final List<MapEntry<String, Map<String, dynamic>>> validRows;
  final List<CsvRowError> failedRows;
  const ParsedCsvResult(this.validRows, this.failedRows);
}

const _requiredColumns = [
  'exam', 'subject', 'chapter', 'topic', 'difficulty', 'question',
  'option_a', 'option_b', 'option_c', 'option_d', 'correct_answer',
  'explanation', 'marks', 'negative_marks', 'source', 'year',
];
const _difficulties = ['easy', 'medium', 'hard'];
const _answerKeys = ['a', 'b', 'c', 'd'];

String slugify(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'(^-|-$)'), '');
}

ParsedCsvResult parseQuestionCsv(String csvContent, Set<String> publishedExamSlugs) {
  final table = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
      .convert(csvContent, fieldDelimiter: ',');
  if (table.isEmpty) return const ParsedCsvResult([], []);

  final header = table.first.map((h) => h.toString().trim()).toList();
  final validRows = <MapEntry<String, Map<String, dynamic>>>[];
  final failedRows = <CsvRowError>[];

  for (var i = 1; i < table.length; i++) {
    final rowNumber = i + 1; // +1 for header, table is 0-indexed
    final rawRow = table[i];
    if (rawRow.every((c) => c.toString().trim().isEmpty)) continue;

    final row = <String, String>{};
    for (var c = 0; c < header.length && c < rawRow.length; c++) {
      row[header[c]] = rawRow[c].toString().trim();
    }

    final errors = _validateRow(row, publishedExamSlugs);
    if (errors.isNotEmpty) {
      failedRows.add(CsvRowError(rowNumber, errors));
      continue;
    }

    final examId = slugify(row['exam']!);
    final subjectId = slugify(row['subject']!);
    final chapterId = slugify(row['chapter']!);
    final topicId = slugify(row['topic']!);
    final correctKey = row['correct_answer']!.toUpperCase();

    final options = [
      {'key': 'A', 'text': row['option_a']!},
      {'key': 'B', 'text': row['option_b']!},
      {'key': 'C', 'text': row['option_c']!},
      {'key': 'D', 'text': row['option_d']!},
    ];

    final idSource = '$examId|$subjectId|$chapterId|$topicId|${row['question']}';
    final id = 'imp_${sha1.convert(utf8.encode(idSource)).toString().substring(0, 24)}';

    validRows.add(MapEntry(id, {
      'examId': examId,
      'subjectId': subjectId,
      'subjectName': row['subject'],
      'chapterId': chapterId,
      'chapterName': row['chapter'],
      'topicId': topicId,
      'topicName': row['topic'],
      'questionType': 'single_choice',
      'difficulty': row['difficulty']!.toLowerCase(),
      'questionText': row['question'],
      'questionImage': null,
      'options': options,
      'correctAnswer': correctKey,
      'explanation': row['explanation'],
      'marks': num.parse(row['marks']!),
      'negativeMarks': num.parse(row['negative_marks']!),
      'source': row['source'],
      'year': row['year']!.isEmpty ? null : int.tryParse(row['year']!),
      'status': 'published',
    }));
  }

  return ParsedCsvResult(validRows, failedRows);
}

List<String> _validateRow(Map<String, String> row, Set<String> publishedExamSlugs) {
  final errors = <String>[];
  for (final col in _requiredColumns) {
    if ((row[col] ?? '').trim().isEmpty) errors.add('missing "$col"');
  }
  if (errors.isNotEmpty) return errors;

  final examSlug = slugify(row['exam']!);
  if (!publishedExamSlugs.contains(examSlug)) {
    errors.add('unknown exam "${row['exam']}" (no published exam with slug "$examSlug")');
  }

  final difficulty = row['difficulty']!.toLowerCase();
  if (!_difficulties.contains(difficulty)) {
    errors.add('difficulty must be one of ${_difficulties.join("/")}, got "${row['difficulty']}"');
  }

  final correctAnswer = row['correct_answer']!.toLowerCase();
  if (!_answerKeys.contains(correctAnswer)) {
    errors.add('correct_answer must be one of ${_answerKeys.join("/")}, got "${row['correct_answer']}"');
  }

  if (num.tryParse(row['marks']!) == null) errors.add('marks is not a number: "${row['marks']}"');
  if (num.tryParse(row['negative_marks']!) == null) {
    errors.add('negative_marks is not a number: "${row['negative_marks']}"');
  }
  final year = row['year']!;
  if (year.isNotEmpty && int.tryParse(year) == null) errors.add('year is not a number: "$year"');

  return errors;
}
