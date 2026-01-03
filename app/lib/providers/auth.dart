import 'package:flutter/foundation.dart';
import 'package:app/models/auth.dart';
import 'package:app/services/auth.dart';

// AuthProvider manages the authentication state of the application.
// It uses ChangeNotifier to notify listeners when the auth state changes.
class AuthProvider with ChangeNotifier {
  AuthState _state = AuthState.unknown();
  final AuthService _authService = AuthService.instance;
  String? _errorMessage;
  bool _isLoading = false;

  // Current authentication state
  AuthState get state => _state;

  // Current authenticated user (null if not authenticated)
  AuthUser? get currentUser => _state.user;

  // Whether the user is authenticated
  bool get isAuthenticated => _state.isAuthenticated;

  // Current authentication status
  AuthStatus get status => _state.status;

  // Last error message (null if no error)
  String? get errorMessage => _errorMessage;

  // Whether an authentication operation is in progress
  bool get isLoading => _isLoading;

  // Clear the error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Check current session and restore user if authenticated
  // This should be called when the app starts
  Future<void> checkSession() async {
    try {
      _setLoading(true);
      final user = await _authService.getCurrentUser();
      _state = AuthState.authenticated(user);
      _errorMessage = null;
    } on AuthException catch (e) {
      if (e.code == 401) {
        _state = AuthState.unauthenticated();
      } else {
        _state = AuthState.unauthenticated();
        _setError(e.message);
      }
    } catch (e) {
      _state = AuthState.unauthenticated();
      _setError('Failed to check session: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Sign up a new user with email and password
  Future<void> signUpWithPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await _authService.signUpWithPassword(
        email: email,
        password: password,
        name: name,
      );

      _state = AuthState.authenticated(user);
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
      rethrow;
    } catch (e) {
      _setError('Signup failed: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Login with email and password
  Future<void> loginWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await _authService.loginWithPassword(
        email: email,
        password: password,
      );

      _state = AuthState.authenticated(user);
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
      rethrow;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Logout the current user
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.logout();
      _state = AuthState.unauthenticated();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      // Even if logout fails, we set state to unauthenticated
      // since cookies are cleared locally
      _state = AuthState.unauthenticated();
      _setError('Logout completed with warnings: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}
