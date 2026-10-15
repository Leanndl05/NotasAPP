import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userSessionKey = 'app_logged_in_user';
  FirebaseAuth? _firebaseAuth;
  bool _isFirebaseAvailable = false;

  bool get isFirebaseAvailable => _isFirebaseAvailable;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firebaseAuth = FirebaseAuth.instance;
        _isFirebaseAvailable = true;
      }
    } catch (_) {
      _isFirebaseAvailable = false;
    }
  }

  Future<AppUser?> getPersistedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userSessionKey);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(userJson);
        return AppUser.fromJson(data);
      } catch (_) {
        return null;
      }
    }

    // Check Firebase current user
    if (_isFirebaseAvailable && _firebaseAuth?.currentUser != null) {
      final fbUser = _firebaseAuth!.currentUser!;
      return AppUser(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName,
      );
    }

    return null;
  }

  Future<void> _persistUser(AppUser? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString(_userSessionKey, jsonEncode(user.toJson()));
    } else {
      await prefs.remove(_userSessionKey);
    }
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    if (_isFirebaseAvailable && _firebaseAuth != null) {
      try {
        final credential = await _firebaseAuth!.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final fbUser = credential.user!;
        final appUser = AppUser(
          uid: fbUser.uid,
          email: fbUser.email ?? cleanEmail,
          displayName: fbUser.displayName,
        );
        await _persistUser(appUser);
        return appUser;
      } on FirebaseAuthException catch (e) {
        throw _parseFirebaseError(e);
      } catch (e) {
        throw 'Error al iniciar sesión: ${e.toString()}';
      }
    } else {
      // Local / Offline authentication fallback
      final uid = 'user_${cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
      final appUser = AppUser(
        uid: uid,
        email: cleanEmail,
        isDemo: true,
      );
      await _persistUser(appUser);
      return appUser;
    }
  }

  Future<AppUser> register({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    if (_isFirebaseAvailable && _firebaseAuth != null) {
      try {
        final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final fbUser = credential.user!;
        final appUser = AppUser(
          uid: fbUser.uid,
          email: fbUser.email ?? cleanEmail,
          displayName: fbUser.displayName,
        );
        await _persistUser(appUser);
        return appUser;
      } on FirebaseAuthException catch (e) {
        throw _parseFirebaseError(e);
      } catch (e) {
        throw 'Error al registrar usuario: ${e.toString()}';
      }
    } else {
      // Local / Offline authentication fallback
      final uid = 'user_${cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
      final appUser = AppUser(
        uid: uid,
        email: cleanEmail,
        isDemo: true,
      );
      await _persistUser(appUser);
      return appUser;
    }
  }

  Future<AppUser> signInAsGuest() async {
    if (_isFirebaseAvailable && _firebaseAuth != null) {
      try {
        final credential = await _firebaseAuth!.signInAnonymously();
        final fbUser = credential.user!;
        final appUser = AppUser(
          uid: fbUser.uid,
          email: 'invitado@notasapp.com',
          displayName: 'Invitado',
          isDemo: true,
        );
        await _persistUser(appUser);
        return appUser;
      } catch (_) {
        // Fallback to local guest if anonymous auth is not enabled in Firebase
      }
    }

    const appUser = AppUser(
      uid: 'guest_user_offline',
      email: 'invitado@notasapp.local',
      displayName: 'Invitado',
      isDemo: true,
    );
    await _persistUser(appUser);
    return appUser;
  }

  Future<void> signOut() async {
    if (_isFirebaseAvailable && _firebaseAuth != null) {
      try {
        await _firebaseAuth!.signOut();
      } catch (_) {}
    }
    await _persistUser(null);
  }

  String _parseFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe ningún usuario registrado con este correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Contraseña o correo electrónico incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-disabled':
        return 'Esta cuenta de usuario ha sido inhabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu conexión a internet.';
      default:
        return e.message ?? 'Ocurrió un error de autenticación (${e.code}).';
    }
  }
}
