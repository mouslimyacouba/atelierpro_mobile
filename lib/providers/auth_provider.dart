import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '569744918009-gvmodq465p6rji52c9t0jnjk9uvql0aq.apps.googleusercontent.com',
  );
  StreamSubscription<User?>? _sub;

  User? _user;
  bool _loading = false;
  bool _initializing = true;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  bool get initializing => _initializing;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  String? get error => _error;

  AuthProvider() {
    _user = _auth.currentUser;
    _initializing = false;
    _sub = _auth.authStateChanges().listen((user) {
      _user = user;
      _initializing = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<String?> signUp({required String email, required String password}) async {
    try {
      _error = null;
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Envoyer l'email de confirmation
      try {
        await credential.user?.sendEmailVerification();
      } catch (e) {
        debugPrint("Erreur envoi email : $e");
      }

      // Déconnexion immédiate pour forcer le retour à l'écran de connexion
      // et attendre la validation de l'email par l'utilisateur.
      await _auth.signOut();

      return null;
    } on FirebaseAuthException catch (e) {
      _error = _translateAuthError(e);
      notifyListeners();
      return _error;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return _error;
    }
  }

  Future<void> sendEmailVerification() async {
    await _user?.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _user?.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      _error = null;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      _error = _translateAuthError(e);
      notifyListeners();
      return _error;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return _error;
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      await _user?.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return _translateAuthError(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> resetPasswordForEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _translateAuthError(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<String?> signInWithGoogle() async {
    try {
      _error = null;
      _loading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _loading = false;
        notifyListeners();
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _loading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      _error = _translateAuthError(e);
      notifyListeners();
      return _error;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return _error;
    }
  }

  String _translateAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé par un autre compte.';
      case 'invalid-email':
        return 'Format d\'adresse email invalide.';
      case 'weak-password':
        return 'Le mot de passe est trop faible (minimum 6 caractères).';
      case 'operation-not-allowed':
        return 'L\'authentification Email/Mot de passe n\'est pas activée dans votre Firebase Console.';
      case 'invalid-api-key':
      case 'api-key-not-valid':
        return 'Clé API Firebase invalide. Ajoutez le fichier google-services.json ou renseignez les clés dans .env.';
      case 'network-request-failed':
        return 'Erreur réseau : vérifiez votre connexion Internet.';
      default:
        return e.message ?? 'Erreur d\'authentification (${e.code}).';
    }
  }
}
