import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { enAttente, enCours, termine, livre }

extension OrderStatusX on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.enAttente:
        return 'en_attente';
      case OrderStatus.enCours:
        return 'en_cours';
      case OrderStatus.termine:
        return 'termine';
      case OrderStatus.livre:
        return 'livre';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.enAttente:
        return 'En attente';
      case OrderStatus.enCours:
        return 'En cours';
      case OrderStatus.termine:
        return 'Terminée';
      case OrderStatus.livre:
        return 'Livrée';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.enAttente:
        return const Color(0xFFD98A3D);
      case OrderStatus.enCours:
        return const Color(0xFF3D6B83);
      case OrderStatus.termine:
        return const Color(0xFF3D8361);
      case OrderStatus.livre:
        return const Color(0xFF2B7A3D);
    }
  }

  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => OrderStatus.enAttente,
    );
  }
}

class AtelierOrder {
  final String id;
  final String userId;
  final String clientId;
  final String? ficheMesureId;
  final String description;
  final OrderStatus status;
  final DateTime dateCommande;
  final DateTime? dateEcheance;
  final double prixTotal;
  final double acompte;
  final DateTime createdAt;
  final String? clientName;

  AtelierOrder({
    required this.id,
    required this.userId,
    required this.clientId,
    this.ficheMesureId,
    required this.description,
    required this.status,
    required this.dateCommande,
    this.dateEcheance,
    required this.prixTotal,
    required this.acompte,
    required this.createdAt,
    this.clientName,
  });

  double get remaining => (prixTotal - acompte).clamp(0, double.infinity);
  bool get isFullyPaid => remaining <= 0;

  double get totalAmount => prixTotal;
  double get paidAmount => acompte;
  DateTime? get dueDate => dateEcheance;

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.parse(val);
    return DateTime.now();
  }

  factory AtelierOrder.fromMap(Map<String, dynamic> map, [String? docId]) {
    String? cName;
    if (map['client_name'] != null) {
      cName = map['client_name'] as String?;
    } else if (map['clients'] is Map) {
      cName = map['clients']['nom_complet'] as String?;
    }

    return AtelierOrder(
      id: docId ?? (map['id'] as String? ?? ''),
      userId: map['user_id'] as String? ?? '',
      clientId: map['client_id'] as String? ?? '',
      ficheMesureId: map['fiche_mesure_id'] as String?,
      description: map['description'] as String? ?? '',
      status: OrderStatusX.fromValue(map['statut'] as String? ?? 'en_attente'),
      dateCommande: _parseDate(map['date_commande']),
      dateEcheance: map['date_echeance'] != null ? _parseDate(map['date_echeance']) : null,
      prixTotal: (map['prix_total'] as num?)?.toDouble() ?? 0.0,
      acompte: (map['acompte'] as num?)?.toDouble() ?? 0.0,
      createdAt: _parseDate(map['created_at']),
      clientName: cName,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'client_id': clientId,
      'client_name': clientName,
      'fiche_mesure_id': ficheMesureId,
      'description': description,
      'statut': status.value,
      'date_commande': Timestamp.fromDate(dateCommande),
      'date_echeance': dateEcheance != null ? Timestamp.fromDate(dateEcheance!) : null,
      'prix_total': prixTotal,
      'acompte': acompte,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
