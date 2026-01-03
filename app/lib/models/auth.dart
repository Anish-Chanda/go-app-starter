enum AuthStatus {
  // The user is logged in
  authenticated,
  // The user is not logged in
  unauthenticated,
  // The app just started, and we havent checked /auth/status yet
  unknown,
}

enum AuthProvider {
  local
  // more providers can be added as needed (google, github, facebook, apple, etc.)
  ;

  // Create AuthProvider from string
  static AuthProvider fromString(String value) {
    try {
      return AuthProvider.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (_) {
      // Default to local if provider string doesn't match
      return AuthProvider.local;
    }
  }

  // Convert to display-friendly string
  String get displayName {
    switch (this) {
      case AuthProvider.local:
        return 'Email/Password';
    }
  }
}

class AuthUser {
  final String name;
  final String email;
  final String picture;
  final AuthProvider provider; // Auth provider (local, google, github, etc.)

  AuthUser({
    required this.name,
    required this.email,
    required this.picture,
    required this.provider,
  });

  // Create an AuthUser from JSON data returned by the API
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    // Extract provider from attrs field
    final attrs = json['attrs'] as Map<String, dynamic>?;
    final providerName = attrs?['provider'] as String? ?? 'local';

    return AuthUser(
      name: json['name'] as String,
      email: (json['email'] as String?) ?? '',
      picture: (json['picture'] as String?) ?? '',
      provider: AuthProvider.fromString(providerName),
    );
  }

  // Convert AuthUser to JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'picture': picture,
      'attrs': <String, dynamic>{'provider': provider.name},
    };
  }
}

class AuthState {
  final AuthStatus status;
  final AuthUser? user;

  AuthState._({required this.status, this.user});

  factory AuthState.unknown() => AuthState._(status: AuthStatus.unknown);

  factory AuthState.authenticated(AuthUser user) =>
      AuthState._(status: AuthStatus.authenticated, user: user);

  factory AuthState.unauthenticated() =>
      AuthState._(status: AuthStatus.unauthenticated);

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
}
