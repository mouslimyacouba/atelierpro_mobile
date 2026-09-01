import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidentialité'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Politique de Confidentialité',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AtelierProColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dernière mise à jour : 31 août 2026',
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: AtelierProColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Introduction',
              'AtelierPro Mobile est conçu pour aider les artisans au Niger à gérer leur atelier. '
                  'La protection de vos données professionnelles et de celles de vos clients est notre priorité.',
            ),
            _buildSection(
              '2. Données Collectées',
              'Nous collectons les informations suivantes pour le bon fonctionnement de l\'application :\n'
                  '• Informations de votre atelier (nom, ville, téléphone, spécialité).\n'
                  '• Informations clients (nom, téléphone, mesures).\n'
                  '• Données de gestion (commandes, fiches de mesures, paiements).',
            ),
            _buildSection(
              '3. Utilisation des Données',
              'Vos données sont utilisées exclusivement pour :\n'
                  '• Vous permettre de gérer vos clients et vos commandes.\n'
                  '• Suivre vos mesures et vos fiches techniques.\n'
                  '• Assurer la synchronisation entre vos appareils via Firebase.',
            ),
            _buildSection(
              '4. Stockage et Sécurité',
              'Vos données sont stockées de manière sécurisée sur les serveurs de Google Firebase. '
                  'L\'accès à vos données est strictement réservé à votre compte via une authentification sécurisée.',
            ),
            _buildSection(
              '5. Vos Droits',
              'Vous restez propriétaire de vos données. Vous disposez d\'un droit d\'accès, de modification '
                  'et de suppression totale de vos données directement depuis les paramètres de l\'application.',
            ),
            _buildSection(
              '6. Contact',
              'Pour toute question concernant vos données, vous pouvez nous contacter via le support WhatsApp '
                  'disponible dans les paramètres.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'AtelierPro - La technologie au service de l\'artisanat nigérien.',
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
