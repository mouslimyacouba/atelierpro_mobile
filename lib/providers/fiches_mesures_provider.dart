import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fiche_mesure.dart';

class FichesMesuresProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _sub;

  List<FicheMesure> _fiches = [];
  bool _loading = false;
  String? _error;

  List<FicheMesure> get fiches => _fiches;
  bool get loading => _loading;
  String? get error => _error;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<FicheMesure> forClient(String clientId) =>
      _fiches.where((f) => f.clientId == clientId).toList();

  String? _currentUserId;

  Future<void> load(String userId) {
    if (_sub != null && _currentUserId == userId) return Future.value();

    _sub?.cancel();
    _currentUserId = userId;
    _loading = true;
    _error = null;
    notifyListeners();

    _sub = _firestore
        .collection('fiches_mesures')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen(
      (snap) {
        _fiches = snap.docs.map((doc) => FicheMesure.fromMap(doc.data(), doc.id)).toList();
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Erreur FichesMesuresProvider: $e");
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );
    return Future.value();
  }

  Future<String?> addFiche(FicheMesure fiche) async {
    try {
      final data = fiche.toInsertMap();
      data['created_at'] = FieldValue.serverTimestamp();
      data['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('fiches_mesures').add(data);
      return null;
    } catch (e) {
      debugPrint("Erreur addFiche: $e");
      return e.toString();
    }
  }

  Future<String?> updateFiche(String id, Map<String, dynamic> changes) async {
    try {
      changes['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('fiches_mesures').doc(id).update(changes);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteFiche(String id) async {
    try {
      await _firestore.collection('fiches_mesures').doc(id).delete();
      _fiches.removeWhere((f) => f.id == id);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  FicheMesure? byId(String id) {
    try {
      return _fiches.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}
