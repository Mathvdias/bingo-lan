import 'package:bingo_app/features/auth/auth_service.dart';
import 'package:bingo_app/shared/services/supabase_service.dart';
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';

enum AuthMethod { google, apple }

class AuthViewModel extends BaseViewModel {
  final AuthService _authService;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isSignedIn;

  AuthViewModel({required AuthService authService})
    : _authService = authService;

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _errorMessage = null;
    setLoading(true);

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential == null) {
        // User canceled
        return false;
      }

      // Sync user to Supabase
      await _syncUserToSupabase(userCredential.user!);

      log('Google Sign-In completed successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } on GoogleSignInException catch (e) {
      // Captura erros específicos do Google Sign In (configuração, cancelamento pelo usuário)
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // Erro 16 (reauth failed) geralmente aparece como canceled/failed
        _errorMessage = 'Login cancelado ou falha de configuração (SHA-1).';
      } else {
        _errorMessage = 'Erro Google Sign-In: ${e.description}';
      }
      log('Google Sign-In Error: ${e.code} - ${e.description}');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erro inesperado ao fazer login com Google';
      log('Unexpected error in signInWithGoogle: $e');
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    _errorMessage = null;
    setLoading(true);

    try {
      final userCredential = await _authService.signInWithApple();

      if (userCredential == null) {
        // User canceled
        return false;
      }

      // Sync user to Supabase
      await _syncUserToSupabase(userCredential.user!);

      log('Apple Sign-In completed successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'Erro inesperado ao fazer login com Apple';
      log('Unexpected error in signInWithApple: $e');
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    setLoading(true);
    try {
      await _authService.signOut();
      log('User signed out successfully');
      notifyListeners();
    } catch (e) {
      log('Error signing out: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Sync Firebase user to Supabase
  Future<void> _syncUserToSupabase(User user) async {
    try {
      // Extract provider info
      final provider = user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : 'unknown';

      await SupabaseService.syncUser(
        firebaseUid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        provider: provider,
      );

      // Log sign-in event
      await SupabaseService.logEvent(
        userId: user.uid,
        eventName: 'user_sign_in',
        eventParams: {'provider': provider},
      );
    } catch (e) {
      log('Error syncing user to Supabase: $e');
      // Don't throw - allow sign-in to complete even if Supabase sync fails
    }
  }

  /// Handle Firebase Auth exceptions
  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        _errorMessage =
            'Uma conta já existe com o mesmo email, mas com credenciais diferentes.';
        break;
      case 'invalid-credential':
        _errorMessage = 'Credenciais inválidas. Tente novamente.';
        break;
      case 'operation-not-allowed':
        _errorMessage = 'Este método de login não está habilitado.';
        break;
      case 'user-disabled':
        _errorMessage = 'Esta conta foi desabilitada.';
        break;
      case 'user-not-found':
        _errorMessage = 'Nenhuma conta encontrada com essas credenciais.';
        break;
      case 'wrong-password':
        _errorMessage = 'Senha incorreta.';
        break;
      default:
        _errorMessage = 'Erro ao fazer login: ${e.message}';
    }
    log('Auth error: ${e.code} - ${e.message}');
    notifyListeners();
  }
}
