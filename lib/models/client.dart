import 'package:cloud_firestore/cloud_firestore.dart';

class AtelierClient {
  final String id;
  final String userId;
  final String nomComplet;
  final String? telephone;
  final String? adresse;
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  AtelierClient({
    required this.id,
    required this.userId,
    required this.nomComplet,
    this.telephone,
    this.adresse,
    this.notes,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.parse(val);
    return DateTime.now();
  }

  factory AtelierClient.fromMap(Map<String, dynamic> map, [String? docId]) {
    return AtelierClient(
      id: docId ?? (map['id'] as String? ?? ''),
      userId: map['user_id'] as String? ?? '',
      nomComplet: map['nom_complet'] as String? ?? '',
      telephone: map['telephone'] as String?,
      adresse: map['adresse'] as String?,
      notes: map['notes'] as String?,
      photoUrl: map['photo_url'] as String?,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'nom_complet': nomComplet,
      'telephone': telephone,
      'adresse': adresse,
      'notes': notes,
      'photo_url': photoUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}
