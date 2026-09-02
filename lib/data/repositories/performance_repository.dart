import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/user_performance_model.dart';

/// Reads server-computed `user_performance` docs (§14) -- never written
/// from the client, only ever produced by `calculatePerformance` (§12).
class PerformanceRepository {
  final FirebaseFirestore _firestore;

  PerformanceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<UserPerformanceModel>> fetchTopicPerformance({
    required String userId,
    required String examId,
  }) async {
    final snap = await _firestore
        .collection(FirestorePaths.userPerformance)
        .where('userId', isEqualTo: userId)
        .where('examId', isEqualTo: examId)
        .where('level', isEqualTo: 'topic')
        .get();
    return snap.docs.map(UserPerformanceModel.fromDoc).toList();
  }

  Future<List<UserPerformanceModel>> fetchSubjectPerformance({
    required String userId,
    required String examId,
  }) async {
    final snap = await _firestore
        .collection(FirestorePaths.userPerformance)
        .where('userId', isEqualTo: userId)
        .where('examId', isEqualTo: examId)
        .where('level', isEqualTo: 'subject')
        .get();
    return snap.docs.map(UserPerformanceModel.fromDoc).toList();
  }
}
