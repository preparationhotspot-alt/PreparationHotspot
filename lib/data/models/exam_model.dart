import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors an `exams/{examId}` document (§7). Admin adds/edits exams from
/// the admin panel -- the Flutter app never needs new code for a new exam.
class ExamModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? icon;
  final String status;
  final int displayOrder;

  const ExamModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.icon,
    required this.status,
    required this.displayOrder,
  });

  factory ExamModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ExamModel(
      id: doc.id,
      name: data['name'] ?? '',
      slug: data['slug'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'],
      status: data['status'] ?? 'draft',
      displayOrder: data['displayOrder'] ?? 0,
    );
  }
}
