import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/study_plan_model.dart';

/// Reads the server-computed `study_plans` doc + items (§16) -- only ever
/// written by `generateStudyPlan` (§30), read-only for the client.
class StudyPlanRepository {
  final FirebaseFirestore _firestore;

  StudyPlanRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<StudyPlanModel?> fetchPlan({
    required String userId,
    required String examId,
  }) async {
    final planId = '${userId}_$examId';
    final planDoc = await _firestore
        .collection(FirestorePaths.studyPlans)
        .doc(planId)
        .get();
    if (!planDoc.exists) return null;

    final itemsSnap = await planDoc.reference
        .collection(FirestorePaths.studyPlanItems)
        .get();
    final items = itemsSnap.docs.map(StudyPlanItemModel.fromDoc).toList();

    return StudyPlanModel.fromDoc(planDoc, items: items);
  }
}
