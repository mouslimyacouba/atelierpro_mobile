import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      // Sur Web, l'initialisation peut être capricieuse si le service worker n'est pas prêt
      if (kIsWeb) {
        // Optionnel : ajouter une logique spécifique Web ici si nécessaire
        return;
      }

      // Demander la permission (iOS/Android 13+)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('Utilisateur a autorisé les notifications');

        // Récupérer le token FCM
        String? token = await _messaging.getToken();
        debugPrint('FCM Token: $token');
      }

      // Gérer les messages en premier plan
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Message reçu en premier plan : ${message.notification?.title}');
      });
    } catch (e) {
      debugPrint('Erreur initialisation notifications : $e');
    }
  }
}
