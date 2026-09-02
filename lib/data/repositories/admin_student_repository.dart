import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/app_user_model.dart';

/// §40: admin-only student listing. Capped and ordered by most-recently-
/// active first, since browsing a growing user base without pagination
/// would violate §52's "avoid unnecessary reads" guidance.
class AdminStudentRepository {
  final FirebaseFirestore _firestore;
  AdminStudentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<AppUserModel>> fetchStudents({int limit = 200}) async {
    final snap = await _firestore
        .collection(FirestorePaths.users)
        .orderBy('lastLoginAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((doc) => AppUserModel.fromMap(doc.id, doc.data())).toList();
  }
}
