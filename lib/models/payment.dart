import 'package:cloud_firestore/cloud_firestore.dart';

class AtelierPayment {
  final String id;
  final String userId;
  final String commandeId;
  final double montant;
  final String mode;
  final DateTime datePaiement;
  final DateTime createdAt;

  AtelierPayment({
    required this.id,
    required this.userId,
    required this.commandeId,
    required this.montant,
    required this.mode,
    required this.datePaiement,
    required this.createdAt,
  });

  static const modeLabels = {
    'especes': 'Espèces',
    'airtel_money': 'Airtel Money',
    'moov_flooz': 'Moov Flooz',
    'wave': 'Wave',
    'zamani_cash': 'Zamani Cash',
    'virement': 'Virement',
    'autre': 'Autre',
  };

  String get modeLabel => modeLabels[mode] ?? mode;

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.parse(val);
    return DateTime.now();
  }

  factory AtelierPayment.fromMap(Map<String, dynamic> map, [String? docId]) {
    return AtelierPayment(
      id: docId ?? (map['id'] as String? ?? ''),
      userId: map['user_id'] as String? ?? '',
      commandeId: map['commande_id'] as String? ?? '',
      montant: (map['montant'] as num?)?.toDouble() ?? 0.0,
      mode: (map['mode'] as String?) ?? 'especes',
      datePaiement: _parseDate(map['date_paiement']),
      createdAt: _parseDate(map['created_at']),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'commande_id': commandeId,
      'montant': montant,
      'mode': mode,
      'date_paiement': Timestamp.fromDate(datePaiement),
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
