import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Authentication status exposed to the widget tree.
enum AuthStatus { unknown, authenticating, authenticated, unauthenticated }

/// Manages auth state via [AuthService] and exposes it as a [ChangeNotifier].
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService {
    _subscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;
  late final StreamSubscription<dynamic> _subscription;

  AuthStatus _status = AuthStatus.unknown;
  String? _uid;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get uid => _uid;
  String? get errorMessage => _errorMessage;

  void _onAuthStateChanged(dynamic user) {
    if (user != null) {
      _uid = (user as dynamic).uid as String;
      _status = AuthStatus.authenticated;
    } else {
      _uid = null;
      _status = AuthStatus.unauthenticated;
    }
    _errorMessage = null;
    notifyListeners();
  }

  /// Signs in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  /// Creates a new account and initialises the Firestore user document.
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      final uid = credential.user?.uid;
      if (uid != null) {
        await _firestoreService.createUserIfMissing(
          uid,
          displayName: displayName,
        );
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  /// Signs out the current user.
  Future<void> signOut() => _authService.signOut();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
