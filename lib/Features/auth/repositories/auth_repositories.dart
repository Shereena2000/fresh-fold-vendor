import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fresh_fold_shop_keeper/Features/auth/model/vendor_model.dart';

// import '../model/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register user with email (for email/password auth)
  Future<void> registerUserWithEmail({
    required String uid,
    required String username,
    required String email,
  }) async {
    VendorModel vendor = VendorModel(
      uid: uid,
      fullName: username,
      email: email,
      createdAt: DateTime.now(),
    );
    await saveVendorData(vendor);
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  Future<void> saveVendorData(VendorModel user) async {
    await _firestore
        .collection('vendor')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> sendEmailVerification() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
}
