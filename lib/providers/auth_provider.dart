// lib/providers/auth_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/demo_data.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, profileIncomplete }

class UserAuthProvider extends ChangeNotifier {
  final bool _demoMode;
  AuthService? _authService;
  FirestoreService? _firestoreService;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  User? _firebaseUser;
  String? _error;
  bool _savingProfile = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  User? get firebaseUser => _firebaseUser;
  String? get error => _error;
  bool get demoMode => _demoMode;
  bool get savingProfile => _savingProfile;

  UserAuthProvider({bool demoMode = false}) : _demoMode = demoMode {
    if (_demoMode) {
      _user = DemoData.currentUser;
      _status = AuthStatus.unauthenticated; // shows login first
    } else {
      _authService = AuthService();
      _firestoreService = FirestoreService();
      // Listen to Firebase Auth state — fires immediately with current user
      _authService!.authStateChanges.listen(_onAuthChanged);
    }
  }

  // ─── Auth state listener ──────────────────────────────────────────────────

  StreamSubscription<UserModel?>? _userSubscription;

  Future<void> _onAuthChanged(User? firebaseUser) async {
    _error = null;
    _firebaseUser = firebaseUser;

    // Clean up old subscription if switching users or signing out
    await _userSubscription?.cancel();
    _userSubscription = null;

    if (firebaseUser == null) {
      // Signed out
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
      return;
    }

    // User is signed in — check if they have an existing profile
    _status = AuthStatus.unknown; // show splash while we fetch
    notifyListeners();

    try {
      // Subscribe to live user updates so points sync immediately
      _userSubscription = _firestoreService!.streamUser(firebaseUser.uid).listen((userModel) {
        if (userModel != null && userModel.heightCm > 0) {
          // ✅ Returning user with complete profile → go straight to HomeScreen
          _user = userModel;
          _status = AuthStatus.authenticated;
        } else {
          // 🆕 New user or incomplete profile → show ProfileSetupScreen
          _status = AuthStatus.profileIncomplete;
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('Firestore stream error: $e');
        _status = AuthStatus.profileIncomplete;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Firestore stream setup error: $e');
      _status = AuthStatus.profileIncomplete;
      notifyListeners();
    }
  }

  // ─── Demo mode ────────────────────────────────────────────────────────────

  void demoSignIn() {
    _user = DemoData.currentUser;
    _status = AuthStatus.authenticated;
    _error = null;
    notifyListeners();
  }

  // ─── Real auth ────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    if (_demoMode) { demoSignIn(); return; }
    _clearError();
    try {
      await _authService!.signInWithGoogle();
      // _onAuthChanged fires automatically after this
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (_demoMode) { demoSignIn(); return; }
    _clearError();
    try {
      await _authService!.signInWithEmail(email, password);
      // _onAuthChanged fires automatically
    } catch (e) {
      _error = _friendlyAuthError(e);
      notifyListeners();
    }
  }

  Future<void> createAccount(String email, String password) async {
    if (_demoMode) { demoSignIn(); return; }
    _clearError();
    try {
      await _authService!.createAccountWithEmail(email, password);
      // _onAuthChanged fires automatically → status becomes profileIncomplete
    } catch (e) {
      _error = _friendlyAuthError(e);
      notifyListeners();
    }
  }

  /// Called from ProfileSetupScreen after user fills in bio data.
  /// Saves to Firestore and transitions to authenticated.
  Future<bool> saveProfile(UserModel user) async {
    if (_demoMode) {
      _user = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }

    _savingProfile = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService!.createOrUpdateUser(user);
      _user = user;
      _status = AuthStatus.authenticated;
      _savingProfile = false;
      notifyListeners();
      return true;
    } catch (e) {
      _savingProfile = false;
      _error = 'Failed to save profile. Check your connection. (${e.toString()})';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    if (_demoMode) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
      return;
    }
    await _authService!.signOut();
    // _onAuthChanged fires with null → sets unauthenticated
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _friendlyAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with that email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Wrong email or password.';
        case 'email-already-in-use':
          return 'An account already exists with that email.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'network-request-failed':
          return 'Network error. Check your connection.';
        default:
          return e.message ?? 'Authentication failed.';
      }
    }
    return 'Error: ${e.toString()}';
  }
}
