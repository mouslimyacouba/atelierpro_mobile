import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/atelier.dart';

class AtelierProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSub;

  Atelier? _atelier;
  bool _loading = true;
  String? _error;

  Atelier? get atelier => _atelier;
  bool get loading => _loading;
  String? get error => _error;

  AtelierProvider() {
    // On ne touche pas à _loading = true ici pour éviter le clignotement au démarrage
    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadForCurrentUser();
      } else {
        _atelier = null;
        _loading = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> loadForCurrentUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint("AtelierProvider: Aucun utilisateur connecté");
      _atelier = null;
      _loading = false;
      notifyListeners();
      return;
    }

    if (_atelier == null) {
      _loading = true;
      notifyListeners();
    }

    try {
      debugPrint("AtelierProvider: Chargement de l'atelier pour $userId");
      final snap = await _firestore
          .collection('ateliers')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        debugPrint("AtelierProvider: Aucun atelier trouvé pour cet utilisateur");
        _atelier = null;
      } else {
        final doc = snap.docs.first;
        debugPrint("AtelierProvider: Atelier trouvé: ${doc.id}");
        _atelier = Atelier.fromMap(doc.data(), doc.id);
      }
      _error = null;
    } catch (e) {
      debugPrint("AtelierProvider Erreur: $e");
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> createAtelier({
    required String nomAtelier,
    String? specialite,
    String? telephone,
    String? ville,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 'Utilisateur non connecté';

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = {
        'user_id': userId,
        'nom_atelier': nomAtelier,
        'specialite': specialite,
        'telephone': telephone,
        'ville': ville,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      debugPrint("AtelierProvider: Tentative d'ajout dans Firestore...");
      final docRef = await _firestore.collection('ateliers').add(data);
      debugPrint("AtelierProvider: Document ajouté ID=${docRef.id}");

      // Pour la mise à jour locale immédiate, on met une date locale
      final localData = Map<String, dynamic>.from(data);
      localData['created_at'] = Timestamp.now();
      localData['updated_at'] = Timestamp.now();

      _atelier = Atelier.fromMap(localData, docRef.id);
      _loading = false;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint("AtelierProvider Erreur createAtelier: $e");
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return _error;
    }
  }

  Future<String?> updateAtelier(Map<String, dynamic> changes) async {
    if (_atelier == null) return 'Aucun atelier chargé';
    try {
      final docId = _atelier!.id;
      final serverChanges = Map<String, dynamic>.from(changes);
      serverChanges['updated_at'] = FieldValue.serverTimestamp();

      // 1. Mise à jour Firestore
      await _firestore.collection('ateliers').doc(docId).update(serverChanges);

      // 2. Mise à jour locale instantanée (pour la fluidité)
      final localData = _atelier!.toInsertMap();
      changes.forEach((key, value) {
        localData[key] = value;
      });
      localData['updated_at'] = DateTime.now();

      _atelier = Atelier.fromMap(localData, docId);
      notifyListeners();

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateLogo(String logoUrl) => updateAtelier({'logo_url': logoUrl});

  Future<String?> deleteAtelier() async {
    if (_atelier == null) return null;
    try {
      await _firestore.collection('ateliers').doc(_atelier!.id).delete();
      _atelier = null;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void reset() {
    _atelier = null;
    _loading = false;
    notifyListeners();
  }
}
