import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';

/// Handles the client-writable subset of `users/{uid}` (profile + onboarding
/// fields). Server-computed performance fields are never touched here --
/// those are Cloud-Function-owned (see firestore.rules).
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> setSelectedExam(String uid, String examId) {
    return _firestore.collection(FirestorePaths.users).doc(uid).update({
      'selectedExamId': examId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeStudentProfile(
    String uid, {
    required int targetExamYear,
    required String academicLevel,
  }) {
    return _firestore.collection(FirestorePaths.users).doc(uid).update({
      'targetExamYear': targetExamYear,
      'academicLevel': academicLevel,
      'onboardingCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
