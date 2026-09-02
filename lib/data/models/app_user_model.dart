import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the `users/{uid}` Firestore document (§6).
///
/// Fields such as [overallAccuracy], [questionsAttempted], etc. are
/// server-computed by Cloud Functions and must never be written by the
/// client directly -- this model is used for reading and for the
/// client-owned subset of fields (profile info, selected exam) only.
class AppUserModel {
  final String uid;
  final String fullName;
  final String email;
  final String? profileImage;
  final String? phone;
  final String? selectedExamId;
  final int? targetExamYear;
  final String? academicLevel;
  final String? preparationLevel;
  final bool onboardingCompleted;
  final bool assessmentCompleted;
  final double overallAccuracy;
  final double overallProgress;
  final int questionsAttempted;
  final int questionsCorrect;
  final int questionsIncorrect;
  final int testsAttempted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  const AppUserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.profileImage,
    this.phone,
    this.selectedExamId,
    this.targetExamYear,
    this.academicLevel,
    this.preparationLevel,
    this.onboardingCompleted = false,
    this.assessmentCompleted = false,
    this.overallAccuracy = 0,
    this.overallProgress = 0,
    this.questionsAttempted = 0,
    this.questionsCorrect = 0,
    this.questionsIncorrect = 0,
    this.testsAttempted = 0,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory AppUserModel.fromMap(String uid, Map<String, dynamic> map) {
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;
    return AppUserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'],
      phone: map['phone'],
      selectedExamId: map['selectedExamId'],
      targetExamYear: map['targetExamYear'],
      academicLevel: map['academicLevel'],
      preparationLevel: map['preparationLevel'],
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      assessmentCompleted: map['assessmentCompleted'] ?? false,
      overallAccuracy: (map['overallAccuracy'] ?? 0).toDouble(),
      overallProgress: (map['overallProgress'] ?? 0).toDouble(),
      questionsAttempted: map['questionsAttempted'] ?? 0,
      questionsCorrect: map['questionsCorrect'] ?? 0,
      questionsIncorrect: map['questionsIncorrect'] ?? 0,
      testsAttempted: map['testsAttempted'] ?? 0,
      createdAt: toDate(map['createdAt']),
      updatedAt: toDate(map['updatedAt']),
      lastLoginAt: toDate(map['lastLoginAt']),
    );
  }

  /// Only the fields a client is allowed to create/update directly.
  /// Performance/scoring fields are intentionally excluded (server-owned).
  Map<String, dynamic> toClientWritableMap() {
    return {
      'fullName': fullName,
      'email': email,
      if (profileImage != null) 'profileImage': profileImage,
      if (phone != null) 'phone': phone,
      if (selectedExamId != null) 'selectedExamId': selectedExamId,
      if (targetExamYear != null) 'targetExamYear': targetExamYear,
      if (academicLevel != null) 'academicLevel': academicLevel,
      'onboardingCompleted': onboardingCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AppUserModel copyWith({
    String? fullName,
    String? email,
    String? profileImage,
    String? phone,
    String? selectedExamId,
    int? targetExamYear,
    String? academicLevel,
    bool? onboardingCompleted,
  }) {
    return AppUserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      selectedExamId: selectedExamId ?? this.selectedExamId,
      targetExamYear: targetExamYear ?? this.targetExamYear,
      academicLevel: academicLevel ?? this.academicLevel,
      preparationLevel: preparationLevel,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      assessmentCompleted: assessmentCompleted,
      overallAccuracy: overallAccuracy,
      overallProgress: overallProgress,
      questionsAttempted: questionsAttempted,
      questionsCorrect: questionsCorrect,
      questionsIncorrect: questionsIncorrect,
      testsAttempted: testsAttempted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }
}
