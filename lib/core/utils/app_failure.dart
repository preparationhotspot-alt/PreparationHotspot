import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_strings.dart';

/// Translates raw Firebase/platform exceptions into user-friendly copy.
/// UI code should always display `AppFailure.friendlyMessage`, never
/// the raw exception (§54: don't expose technical Firebase errors).
class AppFailure {
  final String friendlyMessage;
  final Object original;

  AppFailure(this.friendlyMessage, this.original);

  factory AppFailure.from(Object error) {
    if (error is FirebaseAuthException) {
      return AppFailure(_authMessage(error), error);
    }
    if (error is FirebaseFunctionsException) {
      return AppFailure(_functionsMessage(error), error);
    }
    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return AppFailure(AppStrings.permissionErrorMessage, error);
      }
      return AppFailure(AppStrings.genericErrorMessage, error);
    }
    return AppFailure(AppStrings.genericErrorMessage, error);
  }

  /// Cloud Function `HttpsError` messages are written by us to already be
  /// user-safe (e.g. "No diagnostic configuration for this exam.") -- only
  /// network/internal-plumbing codes get a generic fallback (§54).
  static String _functionsMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Please sign in again to continue.';
      case 'unavailable':
      case 'deadline-exceeded':
        return AppStrings.networkErrorMessage;
      case 'internal':
      case 'unknown':
        return AppStrings.genericErrorMessage;
      default:
        return e.message?.isNotEmpty == true
            ? e.message!
            : AppStrings.genericErrorMessage;
    }
  }

  static String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return AppStrings.networkErrorMessage;
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return AppStrings.authErrorMessage;
    }
  }
}
