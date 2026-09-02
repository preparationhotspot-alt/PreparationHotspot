import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/note_model.dart';

/// §35: admin-only CRUD over `notes`. Writes are rejected by
/// firestore.rules unless the caller carries the `admin` custom claim.
class NoteRepository {
  final FirebaseFirestore _firestore;
  NoteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<NoteModel>> watchNotes({String? examId}) {
    Query<Map<String, dynamic>> query = _firestore.collection(FirestorePaths.notes);
    if (examId != null && examId.isNotEmpty) {
      query = query.where('examId', isEqualTo: examId);
    }
    return query.snapshots().map((snap) => snap.docs.map(NoteModel.fromDoc).toList());
  }

  Future<void> createNote(Map<String, dynamic> data) {
    return _firestore.collection(FirestorePaths.notes).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote(String id, Map<String, dynamic> data) {
    return _firestore.collection(FirestorePaths.notes).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setStatus(String id, String status) {
    return _firestore.collection(FirestorePaths.notes).doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String id) {
    return _firestore.collection(FirestorePaths.notes).doc(id).delete();
  }
}
