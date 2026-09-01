import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conditions Générales d\'Utilisation',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AtelierProColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'En utilisant AtelierPro Mobile, vous acceptez les conditions suivantes.',
              style: GoogleFonts.sourceSans3(
                fontSize: 16,
                color: AtelierProColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Objet du Service',
              'AtelierPro Mobile est un outil de gestion destiné aux artisans nigériens pour faciliter le suivi des clients, des commandes et des mesures.',
            ),
            _buildSection(
              '2. Utilisation du Compte',
              'Vous êtes responsable de la confidentialité de vos identifiants de connexion. Toute activité effectuée depuis votre compte est sous votre responsabilité.',
            ),
            _buildSection(
              '3. Données et Contenu',
              'Vous vous engagez à ne pas saisir de données illégales ou offensantes. Vous conservez l\'entière responsabilité des informations saisies (mesures, noms de clients, etc.).',
            ),
            _buildSection(
              '4. Disponibilité du Service',
              'Bien que nous fassions de notre mieux pour assurer une disponibilité 24h/24, nous ne pouvons garantir une absence totale d\'interruptions liées à la maintenance ou à des pannes techniques.',
            ),
            _buildSection(
              '5. Modification des Conditions',
              'Nous nous réservons le droit de modifier ces conditions à tout moment. Vous serez informé de tout changement important via l\'application.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'AtelierPro Mobile - Fièrement conçu pour le Niger.',
                textAlign: TextAlign.center,
                style: GoogleFonts.sourceSans3(
                  fontSize: 12,
                  color: AtelierProColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AtelierProColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.sourceSans3(
              fontSize: 16,
              height: 1.5,
              color: AtelierProColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
