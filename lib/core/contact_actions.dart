import 'package:url_launcher/url_launcher.dart';

/// Normalise un numéro nigérien pour l'international : ajoute l'indicatif
/// +227 si le numéro local (8 chiffres) ne l'a pas déjà. Reste permissif
/// pour les numéros déjà internationaux (garde tel quel si >8 chiffres).
String _normalizePhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.startsWith('+')) return digits;
  if (digits.startsWith('227')) return '+$digits';
  if (digits.length == 8) return '+227$digits';
  return '+$digits';
}

Future<void> callPhone(String rawPhone) async {
  final phone = _normalizePhone(rawPhone);
  final uri = Uri(scheme: 'tel', path: phone);
  await launchUrl(uri);
}

Future<void> openWhatsApp(String rawPhone, {String? message}) async {
  final phone = _normalizePhone(rawPhone).replaceAll('+', '');
  final text = message != null ? '?text=${Uri.encodeComponent(message)}' : '';
  final uri = Uri.parse('https://wa.me/$phone$text');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
