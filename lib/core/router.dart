import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/atelier_provider.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/shell/app_shell.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/clients/client_detail_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/new_order_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/mesures/mesures_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/privacy_policy_screen.dart';
import '../screens/settings/terms_screen.dart';

GoRouter buildRouter(AuthProvider auth, AtelierProvider atelierProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: Listenable.merge([auth, atelierProvider]),
    redirect: (context, state) {
      // 1. Attendre que l'authentification soit initialisée
      if (auth.initializing) return null;

      final loggedIn = auth.user != null;
      final loggingIn = state.matchedLocation == '/auth';
      final onboarding = state.matchedLocation == '/onboarding';

      // 2. Gestion de la connexion
      if (!loggedIn) return loggingIn ? null : '/auth';
      if (loggedIn && loggingIn) return '/';

      // 3. Attendre que l'atelier soit chargé avant de décider pour l'onboarding
      if (loggedIn && atelierProvider.loading) return null;

      // 4. Redirection vers onboarding si pas d'atelier
      if (loggedIn && atelierProvider.atelier == null && !onboarding) {
        return '/onboarding';
      }

      // 5. Sortir de l'onboarding si l'atelier est créé
      if (loggedIn && atelierProvider.atelier != null && onboarding) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/clients', builder: (context, state) => const ClientsScreen()),
          GoRoute(
            path: '/clients/:clientId',
            builder: (context, state) =>
                ClientDetailScreen(clientId: state.pathParameters['clientId']!),
          ),
          GoRoute(path: '/commandes', builder: (context, state) => const OrdersScreen()),
          GoRoute(
            path: '/commandes/nouvelle',
            builder: (context, state) =>
                NewOrderScreen(initialClientId: state.uri.queryParameters['clientId']),
          ),
          GoRoute(
            path: '/commandes/:orderId',
            builder: (context, state) =>
                OrderDetailScreen(orderId: state.pathParameters['orderId']!),
          ),
          GoRoute(path: '/mesures', builder: (context, state) => const MesuresScreen()),
          GoRoute(path: '/parametres', builder: (context, state) => const SettingsScreen()),
          GoRoute(path: '/confidentialite', builder: (context, state) => const PrivacyPolicyScreen()),
          GoRoute(path: '/conditions', builder: (context, state) => const TermsScreen()),
        ],
      ),
    ],
  );
}
