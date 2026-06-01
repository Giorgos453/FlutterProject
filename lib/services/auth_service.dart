import 'package:firebase_auth/firebase_auth.dart';

/// Human-readable authentication error.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thin wrapper around [FirebaseAuth] — no UI logic, no Flutter imports.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Current authenticated user, if any.
  User? get currentUser => _auth.currentUser;

  /// Emits the current user on every auth-state change.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in with email and password.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _translate(e);
    }
  }

  /// Creates a new account with email, password, and display name.
  Future<UserCredential> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _translate(e);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() => _auth.signOut();

  static AuthException _translate(FirebaseAuthException e) {
    final message = switch (e.code) {
      'wrong-password' || 'invalid-credential' =>
        'Incorrect email or password.',
      'user-not-found' => 'No account found for this email.',
      'email-already-in-use' => 'This email is already registered.',
      'invalid-email' => 'Please enter a valid email address.',
      'weak-password' => 'Password is too weak — use at least 6 characters.',
      'network-request-failed' =>
        'Network error — check your connection and try again.',
      'too-many-requests' => 'Too many attempts — please wait and try again.',
      _ => e.message ?? 'Authentication failed. Please try again.',
    };
    return AuthException(message);
  }
}
