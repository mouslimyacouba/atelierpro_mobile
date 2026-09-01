import 'package:cloud_firestore/cloud_firestore.dart';

class FicheMesure {
  final String id;
  final String userId;
  final String clientId;
  final String titre;
  final Map<String, dynamic> mesures;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FicheMesure({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.titre,
    required this.mesures,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.parse(val);
    return DateTime.now();
  }

  factory FicheMesure.fromMap(Map<String, dynamic> map, [String? docId]) {
    return FicheMesure(
      id: docId ?? (map['id'] as String? ?? ''),
      userId: map['user_id'] as String? ?? '',
      clientId: map['client_id'] as String? ?? '',
      titre: (map['titre'] as String?) ?? 'Mesures',
      mesures: Map<String, dynamic>.from(map['mesures'] as Map? ?? {}),
      notes: map['notes'] as String?,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'client_id': clientId,
      'titre': titre,
      'mesures': mesures,
      'notes': notes,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  static const champsSuggeres = [
    'Épaule (Carrure)',
    'Longueur Boubou/Robe',
    'Tour de Poitrine',
    'Tour de Taille',
    'Tour de Hanches',
    'Longueur Manche',
    'Tour de Bras (Biceps)',
    'Tour de Cou',
    'Longueur Pantalon/Pagne',
    'Tour de Cuisse',
    'Bas de Pantalon',
    'Poignet',
    'Hauteur de Taille',
  ];
}
