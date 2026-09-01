import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

import 'core/theme.dart';
import 'core/router.dart';
import 'core/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/atelier_provider.dart';
import 'providers/clients_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/fiches_mesures_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Optionnel si les variables ne sont pas dans .env
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialisation des notifications (sans await pour ne pas bloquer le démarrage sur Web)
  NotificationService.initialize();

  runApp(const AtelierProApp());
}

class AtelierProApp extends StatefulWidget {
  const AtelierProApp({super.key});

  @override
  State<AtelierProApp> createState() => _AtelierProAppState();
}

class _AtelierProAppState extends State<AtelierProApp> {
  late final AuthProvider _auth;
  late final AtelierProvider _atelier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    _atelier = AtelierProvider();
    _router = buildRouter(_auth, _atelier);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
        ChangeNotifierProvider.value(value: _atelier),
        ChangeNotifierProvider(create: (_) => ClientsProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => FichesMesuresProvider()),
      ],
      child: MaterialApp.router(
        title: 'AtelierPro',
        debugShowCheckedModeBanner: false,
        theme: AtelierProTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
