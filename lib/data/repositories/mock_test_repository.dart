import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/mock_test_model.dart';

/// §39: admin-only CRUD over `mock_tests`. Writes are rejected by
/// firestore.rules unless the caller carries the `admin` custom claim.
class MockTestRepository {
  final FirebaseFirestore _firestore;
  MockTestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<MockTestModel>> watchMockTests() {
    return _firestore
        .collection(FirestorePaths.mockTests)
        .snapshots()
        .map((snap) => snap.docs.map(MockTestModel.fromDoc).toList());
  }

  Future<void> createMockTest(Map<String, dynamic> data) {
    return _firestore.collection(FirestorePaths.mockTests).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMockTest(String id, Map<String, dynamic> data) {
    return _firestore.collection(FirestorePaths.mockTests).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setStatus(String id, String status) {
    return _firestore.collection(FirestorePaths.mockTests).doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMockTest(String id) {
    return _firestore.collection(FirestorePaths.mockTests).doc(id).delete();
  }
}
