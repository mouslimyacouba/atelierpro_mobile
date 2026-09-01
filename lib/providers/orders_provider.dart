import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import '../models/payment.dart';

class OrdersProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _sub;

  List<AtelierOrder> _orders = [];
  bool _loading = false;
  String? _error;

  List<AtelierOrder> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<AtelierOrder> byStatus(OrderStatus status) =>
      _orders.where((o) => o.status == status).toList();

  double get chiffreAffairesTotal =>
      _orders.fold(0, (acc, o) => acc + o.prixTotal);

  double get montantRestantDu =>
      _orders.fold(0, (acc, o) => acc + o.remaining);

  List<AtelierOrder> get enRetard {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return _orders.where((o) {
      if (o.dateEcheance == null) return false;
      if (o.status == OrderStatus.livre) return false;
      return o.dateEcheance!.isBefore(todayOnly);
    }).toList();
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
        .collection('commandes')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen(
      (snap) {
        _orders = snap.docs.map((doc) => AtelierOrder.fromMap(doc.data(), doc.id)).toList();
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Erreur OrdersProvider: $e");
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );
    return Future.value();
  }

  Future<String?> createOrder(AtelierOrder order) async {
    try {
      final data = order.toInsertMap();
      data['created_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('commandes').add(data);
      return null;
    } catch (e) {
      debugPrint("Erreur createOrder: $e");
      return e.toString();
    }
  }

  Future<String?> updateStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore
          .collection('commandes')
          .doc(orderId)
          .update({'statut': status.value});
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateOrder(
    String orderId, {
    String? description,
    double? prixTotal,
    DateTime? dateEcheance,
    String? ficheMesureId,
  }) async {
    try {
      final changes = <String, dynamic>{
        if (description != null) 'description': description,
        if (prixTotal != null) 'prix_total': prixTotal,
        if (dateEcheance != null) 'date_echeance': Timestamp.fromDate(dateEcheance),
        'fiche_mesure_id': ficheMesureId,
      };
      await _firestore.collection('commandes').doc(orderId).update(changes);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('commandes').doc(orderId).delete();
      _orders.removeWhere((o) => o.id == orderId);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> recordPayment({
    required String orderId,
    required String userId,
    required double amount,
    required String mode,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. Créer le document de paiement
      final paymentRef = _firestore.collection('paiements').doc();
      batch.set(paymentRef, {
        'user_id': userId,
        'commande_id': orderId,
        'montant': amount,
        'mode': mode,
        'date_paiement': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      });

      // 2. Mettre à jour l'acompte de la commande de manière atomique
      final orderRef = _firestore.collection('commandes').doc(orderId);
      batch.update(orderRef, {
        'acompte': FieldValue.increment(amount),
      });

      await batch.commit();
      return null;
    } catch (e) {
      debugPrint("Erreur recordPayment: $e");
      return e.toString();
    }
  }

  Future<List<AtelierPayment>> paymentsForOrder(String orderId) async {
    try {
      final snap = await _firestore
          .collection('paiements')
          .where('commande_id', isEqualTo: orderId)
          .orderBy('date_paiement', descending: true)
          .get();
      return snap.docs.map((doc) => AtelierPayment.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      return [];
    }
  }

  AtelierOrder? byId(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}
