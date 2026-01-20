import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:developer';

/// Service responsible for handling authentication with Firebase
/// Supports Google Sign-In and Apple Sign-In
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // GoogleSignIn with scopes parameter
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    _googleSignIn = GoogleSignIn.instance;
  }

  /// Gets the current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      log('Google Sign-In successful: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      log('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );

      log('Apple Sign-In successful: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      log('Error signing in with Apple: $e');
      rethrow;
    }
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
      log('Sign-out successful');
    } catch (e) {
      log('Error signing out: $e');
      rethrow;
    }
  }

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Get user display name
  String? get userDisplayName => currentUser?.displayName;

  /// Get user email
  String? get userEmail => currentUser?.email;

  /// Get user photo URL
  String? get userPhotoUrl => currentUser?.photoURL;

  /// Get user ID
  String? get userId => currentUser?.uid;
}
