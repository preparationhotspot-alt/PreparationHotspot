import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/exam_model.dart';

class ExamRepository {
  final FirebaseFirestore _firestore;

  ExamRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ExamModel>> fetchPublishedExams() async {
    final snapshot = await _firestore
        .collection(FirestorePaths.exams)
        .where('status', isEqualTo: 'published')
        .orderBy('displayOrder')
        .get();
    return snapshot.docs.map(ExamModel.fromDoc).toList();
  }

  Future<ExamModel?> fetchExamById(String examId) async {
    final doc = await _firestore.collection(FirestorePaths.exams).doc(examId).get();
    if (!doc.exists) return null;
    return ExamModel.fromDoc(doc);
  }

  // ---------- Admin-only (§33): writes are rejected by firestore.rules
  // unless the caller's ID token carries the `admin` custom claim. ----------

  Stream<List<ExamModel>> watchAllExams() {
    return _firestore
        .collection(FirestorePaths.exams)
        .orderBy('displayOrder')
        .snapshots()
        .map((snap) => snap.docs.map(ExamModel.fromDoc).toList());
  }

  Future<void> createExam({
    required String id,
    required String name,
    required String slug,
    required String description,
    String? icon,
    required int displayOrder,
  }) {
    return _firestore.collection(FirestorePaths.exams).doc(id).set({
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'status': 'draft',
      'displayOrder': displayOrder,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateExam(
    String examId, {
    required String name,
    required String description,
    String? icon,
    required int displayOrder,
  }) {
    return _firestore.collection(FirestorePaths.exams).doc(examId).update({
      'name': name,
      'description': description,
      'icon': icon,
      'displayOrder': displayOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setExamStatus(String examId, String status) {
    return _firestore.collection(FirestorePaths.exams).doc(examId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteExam(String examId) {
    return _firestore.collection(FirestorePaths.exams).doc(examId).delete();
  }
}
