import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:developer';
import 'dart:async';

/// Service responsible for handling authentication with Firebase
/// Supports Google Sign-In and Apple Sign-In
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Google Sign-In instance (singleton)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleSignInInitialized = false;
  GoogleSignInAccount? _lastGoogleUser;

  /// Initialize Google Sign-In with proper configuration
  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;

    try {
      await _googleSignIn.initialize(
        // Firebase Web Client ID (Type 3) from google-services.json
        serverClientId:
            '46563147810-691otkpfrfu1uj2m760g6vadmho2fj53.apps.googleusercontent.com',
      );

      // Listen to authentication events
      _googleSignIn.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          _lastGoogleUser = event.user;
        } else {
          _lastGoogleUser = null;
        }
      });

      _googleSignInInitialized = true;
      log('Google Sign-In initialized successfully');
    } catch (e) {
      log('Error initializing Google Sign-In: $e');
    }
  }

  /// Gets the current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Ensure Google Sign-In is initialized
      await _ensureGoogleSignInInitialized();

      // Trigger the authentication flow
      await _googleSignIn.authenticate();

      // Wait a moment for the event listener to update _lastGoogleUser
      await Future.delayed(const Duration(milliseconds: 500));

      final GoogleSignInAccount? googleUser = _lastGoogleUser;

      if (googleUser == null) {
        log('Google Sign-In canceled or failed');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken, // Use idToken as the access token
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      log('Google Sign-In successful: ${userCredential.user?.email}');
      return userCredential;
    } on GoogleSignInException catch (e) {
      log('Google Sign-In exception: ${e.code} - ${e.description}');
      rethrow;
    } catch (e) {
      log('Unexpected error in signInWithGoogle: $e');
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
      await Future.wait([
        _firebaseAuth.signOut(),
        if (_googleSignInInitialized) _googleSignIn.disconnect(),
      ]);
      _lastGoogleUser = null;
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
