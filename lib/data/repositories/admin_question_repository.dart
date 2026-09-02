import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/admin_question_model.dart';

/// Admin-only CRUD + bulk import over `questions` (§36-§37). All writes
/// are rejected by firestore.rules unless the caller's ID token carries
/// the `admin` custom claim.
class AdminQuestionRepository {
  final FirebaseFirestore _firestore;
  AdminQuestionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Capped at 300 -- browsing/search UI, not a full-bank export (§52).
  Future<List<AdminQuestionModel>> fetchQuestions({String? examId}) async {
    Query<Map<String, dynamic>> query = _firestore.collection(FirestorePaths.questions);
    if (examId != null && examId.isNotEmpty) {
      query = query.where('examId', isEqualTo: examId);
    }
    final snap = await query.limit(300).get();
    return snap.docs.map(AdminQuestionModel.fromDoc).toList();
  }

  Future<void> createQuestion(String id, Map<String, dynamic> data) {
    return _firestore.collection(FirestorePaths.questions).doc(id).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateQuestion(String id, Map<String, dynamic> data) {
    return _firestore.collection(FirestorePaths.questions).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setStatus(String id, String status) {
    return _firestore.collection(FirestorePaths.questions).doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteQuestion(String id) {
    return _firestore.collection(FirestorePaths.questions).doc(id).delete();
  }

  /// Batched upsert for CSV import -- Firestore batches cap at 500 writes,
  /// so this chunks automatically.
  Future<void> bulkUpsert(List<MapEntry<String, Map<String, dynamic>>> rows) async {
    const chunkSize = 400;
    for (var i = 0; i < rows.length; i += chunkSize) {
      final chunk = rows.skip(i).take(chunkSize);
      final batch = _firestore.batch();
      final now = FieldValue.serverTimestamp();
      for (final row in chunk) {
        batch.set(
          _firestore.collection(FirestorePaths.questions).doc(row.key),
          {...row.value, 'createdAt': now, 'updatedAt': now},
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    }
  }
}
