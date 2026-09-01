import 'package:cloud_firestore/cloud_firestore.dart';

class Atelier {
  final String id;
  final String userId;
  final String nomAtelier;
  final String? telephone;
  final String? ville;
  final String? specialite;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Atelier({
    required this.id,
    required this.userId,
    required this.nomAtelier,
    this.telephone,
    this.ville,
    this.specialite,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.parse(val);
    return DateTime.now();
  }

  factory Atelier.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Atelier(
      id: docId ?? (map['id'] as String? ?? ''),
      userId: map['user_id'] as String? ?? '',
      nomAtelier: map['nom_atelier'] as String? ?? '',
      telephone: map['telephone'] as String?,
      ville: map['ville'] as String?,
      specialite: map['specialite'] as String?,
      logoUrl: map['logo_url'] as String?,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'nom_atelier': nomAtelier,
      'telephone': telephone,
      'ville': ville,
      'specialite': specialite,
      'logo_url': logoUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  static const specialiteSuggestions = [
    'Couture / Confection',
    'Sérigraphie',
    'Menuiserie',
    'Métallerie',
    'Maroquinerie',
    'Autre',
  ];

  String get specialiteLabel => specialite ?? 'Non renseignée';
}
