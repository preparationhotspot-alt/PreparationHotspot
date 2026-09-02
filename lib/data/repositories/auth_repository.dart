import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/app_user_model.dart';

/// Owns all Firebase Authentication + `users/{uid}` bootstrap logic.
/// This is the only layer that talks to FirebaseAuth/GoogleSignIn directly;
/// controllers call through here.
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(fullName);
    await _ensureUserDocument(
      credential.user!,
      fullNameOverride: fullName,
    );
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google sign-in was cancelled.',
      );
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    await _ensureUserDocument(userCredential.user!);
    return userCredential;
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Creates `users/{uid}` on first login only; never overwrites an
  /// existing document (would clobber server-computed performance fields).
  Future<void> _ensureUserDocument(User user, {String? fullNameOverride}) async {
    final docRef = _firestore.collection(FirestorePaths.users).doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'fullName': fullNameOverride ?? user.displayName ?? '',
        'email': user.email ?? '',
        'profileImage': user.photoURL,
        'onboardingCompleted': false,
        'assessmentCompleted': false,
        'overallAccuracy': 0,
        'overallProgress': 0,
        'questionsAttempted': 0,
        'questionsCorrect': 0,
        'questionsIncorrect': 0,
        'testsAttempted': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({'lastLoginAt': FieldValue.serverTimestamp()});
    }
  }

  Future<AppUserModel?> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
    if (!doc.exists) return null;
    return AppUserModel.fromMap(uid, doc.data()!);
  }
}
