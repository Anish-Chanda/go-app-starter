import 'package:app/models/auth.dart';
import 'package:dio/dio.dart';
import 'http.dart';

// Custom exception for authentication errors
class AuthException implements Exception {
  final int code;
  final String message;

  AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException($code): $message';
}

// AuthService handles all authentication-related HTTP requests.
// This is a singleton class that should be accessed via AuthService.instance.
// State management is handled by AuthProvider.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final _httpClient = HttpClient.instance;

  // Sign up a new user with email and password
  //
  // Throws [AuthException] if signup fails
  // Returns the created [AuthUser] on success
  Future<AuthUser> signUpWithPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _httpClient.dio.post(
        '/auth/local/signup',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'name': name.trim(),
        },
      );

      if (response.statusCode == 201) {
        // After signup, we need to login to get the session cookie
        return await loginWithPassword(email: email, password: password);
      } else {
        final errorMessage = response.data['error'] ?? response.data.toString();
        throw AuthException(
          response.statusCode ?? 500,
          'Signup failed: $errorMessage',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw AuthException(409, 'An account with this email already exists');
      } else if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?.toString() ?? 'Invalid request';
        throw AuthException(400, errorMessage);
      } else {
        throw AuthException(
          503,
          'Failed to connect to server. Please check your internet connection.',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(500, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Login user with email and password
  //
  // Throws [AuthException] if login fails
  // Returns the authenticated [AuthUser] on success
  // The session cookie is automatically stored by the HTTP client
  Future<AuthUser> loginWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.dio.post(
        '/auth/local/login',
        data: {'user': email.trim().toLowerCase(), 'passwd': password},
      );

      if (response.statusCode == 200) {
        // Login successful, parse user from response
        final data = response.data as Map<String, dynamic>;
        return AuthUser.fromJson(data);
      } else {
        final errorMessage = response.data['error'] ?? 'Login failed';
        throw AuthException(
          response.statusCode ?? 500,
          'Login failed: $errorMessage',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw AuthException(403, 'Invalid email or password');
      } else if (e.response?.statusCode == 400) {
        throw AuthException(400, 'Please provide both email and password');
      } else {
        throw AuthException(
          503,
          'Failed to connect to server. Please check your internet connection.',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(500, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Get the currently authenticated user
  //
  // Throws [AuthException] if not authenticated or if the request fails
  // Returns the current [AuthUser]
  Future<AuthUser> getCurrentUser() async {
    try {
      final response = await _httpClient.dio.get('/auth/user');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return AuthUser.fromJson(data);
      } else {
        throw AuthException(
          response.statusCode ?? 401,
          'User is not authenticated',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException(401, 'User is not authenticated');
      } else {
        throw AuthException(
          e.response?.statusCode ?? 503,
          'Failed to fetch user information',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(500, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Logout the current user
  //
  // Clears the session cookie and calls the logout endpoint
  Future<void> logout() async {
    try {
      // Call logout endpoint to invalidate the session on the server
      await _httpClient.dio.get('/auth/logout');
    } catch (e) {
      // Even if the logout endpoint fails, we still clear local cookies
      // This ensures the user is logged out locally
    } finally {
      // Clear cookies to remove the session
      await HttpClient.instance.clearCookies();
    }
  }
}
