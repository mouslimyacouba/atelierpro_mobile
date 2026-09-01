import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';

class ClientsProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _sub;

  List<AtelierClient> _clients = [];
  bool _loading = false;
  String? _error;

  List<AtelierClient> get clients => _clients;
  bool get loading => _loading;
  String? get error => _error;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String? _currentUserId;

  Future<void> load(String userId) {
    if (_sub != null && _currentUserId == userId) return Future.value();

    _sub?.cancel();
    _currentUserId = userId;
    _loading = true;
    _error = null;
    notifyListeners();

    _sub = _firestore
        .collection('clients')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen(
      (snap) {
        _clients = snap.docs.map((doc) => AtelierClient.fromMap(doc.data(), doc.id)).toList();
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Erreur ClientsProvider: $e");
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );
    return Future.value();
  }

  Future<String?> addClient(AtelierClient client) async {
    try {
      final data = client.toInsertMap();
      // On utilise le timestamp du serveur pour éviter les erreurs d'index/tri
      data['created_at'] = FieldValue.serverTimestamp();
      data['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('clients').add(data);
      return null;
    } catch (e) {
      debugPrint("Erreur addClient: $e");
      return e.toString();
    }
  }

  Future<String?> updateClient(String id, Map<String, dynamic> changes) async {
    try {
      changes['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('clients').doc(id).update(changes);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updatePhoto(String clientId, String photoUrl) =>
      updateClient(clientId, {'photo_url': photoUrl});

  Future<String?> deleteClient(String id) async {
    try {
      await _firestore.collection('clients').doc(id).delete();
      _clients.removeWhere((c) => c.id == id);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  AtelierClient? byId(String id) {
    try {
      return _clients.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
