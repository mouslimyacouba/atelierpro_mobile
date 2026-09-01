import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/fiches_mesures_provider.dart';
import '../../widgets/spinner.dart';

final _money = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

String _salutation() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Bonjour';
  if (hour < 18) return 'Bon après-midi';
  return 'Bonsoir';
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialized = false;
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    final auth = context.read<AuthProvider>();
    if (auth.user != null && !auth.isEmailVerified) {
      _verificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        await auth.reloadUser();
        if (auth.isEmailVerified) {
          timer.cancel();
        }
      });
    }
  }

  Future<void> _triggerSync() async {
    final userId = context.read<AtelierProvider>().atelier?.userId;
    if (userId == null) return;
    await Future.wait([
      context.read<OrdersProvider>().load(userId),
      context.read<ClientsProvider>().load(userId),
      context.read<FichesMesuresProvider>().load(userId),
    ]);
  }

  Future<void> _shareBilan() async {
    final atelier = context.read<AtelierProvider>().atelier;
    final orders = context.read<OrdersProvider>();
    final clients = context.read<ClientsProvider>();
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final buffer = StringBuffer();
    buffer.writeln('📊 *Bilan — ${atelier?.nomAtelier ?? 'Mon atelier'}*');
    buffer.writeln('Au $today');
    buffer.writeln('—————————————');
    buffer.writeln('💰 Chiffre d\'affaires : ${_money.format(orders.chiffreAffairesTotal)}');
    buffer.writeln('⏳ Reste à encaisser : ${_money.format(orders.montantRestantDu)}');
    buffer.writeln('👥 Clients : ${clients.clients.length}');
    buffer.writeln('🧵 Commandes : ${orders.orders.length}');
    if (orders.enRetard.isNotEmpty) {
      buffer.writeln('⚠️ Commandes en retard : ${orders.enRetard.length}');
    }
    buffer.writeln('—————————————');
    buffer.writeln('Généré avec AtelierPro');

    await Share.share(buffer.toString(), subject: 'Bilan atelier — $today');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final atelier = context.watch<AtelierProvider>().atelier;
    if (atelier != null && !_initialized) {
      _initialized = true;
      _triggerSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final atelierProvider = context.watch<AtelierProvider>();
    final atelier = atelierProvider.atelier;
    final orders = context.watch<OrdersProvider>();
    final clients = context.watch<ClientsProvider>();

    // S'assurer que les données sont chargées dès que l'atelier est prêt
    if (atelier != null) {
      _triggerSync();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(atelier?.nomAtelier ?? 'Atelier Niger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: AtelierProColors.primary),
            tooltip: 'Partager le bilan',
            onPressed: _shareBilan,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AtelierProColors.primary),
            tooltip: 'Paramètres',
            onPressed: () => context.go('/parametres'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await auth.reloadUser();
          await _triggerSync();
        },
        child: orders.loading && orders.orders.isEmpty
            ? const AtelierSpinner()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Banner Vérification Email
                  if (auth.user != null && !auth.isEmailVerified)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AtelierProColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AtelierProColors.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.mail_outline, color: AtelierProColors.secondary),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Merci de confirmer votre adresse e-mail pour sécuriser votre compte.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AtelierProColors.primary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await auth.sendEmailVerification();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('E-mail de confirmation envoyé !')),
                                    );
                                  }
                                },
                                child: const Text('Renvoyer'),
                              ),
                            ],
                          ),
                          const Divider(height: 10),
                          const Text(
                            'Une fois confirmé, tirez vers le bas pour rafraîchir.',
                            style: TextStyle(fontSize: 11, color: AtelierProColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),

                  // En-tête Salutation Stitch
                  Text(
                    '${_salutation()}, Artisan 👋',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AtelierProColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Voici le résumé de votre activité aujourd\'hui.',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 15,
                      color: AtelierProColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bento Grid Dashboard Stitch
                  // 1. Grande carte : Commandes en cours
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AtelierProColors.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'COMMANDES EN COURS',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AtelierProColors.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${orders.orders.where((o) => o.status == OrderStatus.enCours || o.status == OrderStatus.enAttente).length}',
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AtelierProColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AtelierProColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pending_actions,
                            color: AtelierProColors.secondary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Grille 2 colonnes : Clients & CA
                  Row(
                    children: [
                      // Total Clients
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AtelierProColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AtelierProColors.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.group_outlined,
                                  size: 18,
                                  color: AtelierProColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${clients.clients.length}',
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AtelierProColors.primary,
                                ),
                              ),
                              Text(
                                'Clients enregistrés',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: AtelierProColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Chiffre d'Affaires Total
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AtelierProColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AtelierProColors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.payments_outlined,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _money.format(orders.chiffreAffairesTotal),
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'CA total',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Alerte commandes en retard (si existantes)
                  if (orders.enRetard.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AtelierProColors.rougeAlerte.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AtelierProColors.rougeAlerte.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AtelierProColors.rougeAlerte),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${orders.enRetard.length} commande(s) en retard de livraison',
                              style: GoogleFonts.sourceSans3(
                                fontWeight: FontWeight.w600,
                                color: AtelierProColors.rougeAlerte,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/commandes'),
                            child: const Text('Voir'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Section Dernières Commandes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dernières Commandes',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AtelierProColors.primary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/commandes'),
                        child: Text(
                          'Voir tout',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AtelierProColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (orders.orders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Aucune commande pour le moment',
                          style: GoogleFonts.sourceSans3(color: AtelierProColors.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    for (final order in orders.orders.take(5))
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () => context.go('/commandes/${order.id}'),
                          leading: CircleAvatar(
                            backgroundColor: AtelierProColors.surfaceContainerHigh,
                            child: Text(
                              order.clientName?.substring(0, order.clientName!.length.clamp(0, 2)).toUpperCase() ?? 'CL',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AtelierProColors.onSurface,
                              ),
                            ),
                          ),
                          title: Text(
                            order.clientName ?? 'Client',
                            style: GoogleFonts.sourceSans3(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            order.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sourceSans3(fontSize: 13),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _money.format(order.prixTotal),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AtelierProColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: order.status.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  order.status.label,
                                  style: TextStyle(
                                    color: order.status.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 80),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/commandes/nouvelle'),
        icon: const Icon(Icons.add),
        label: Text(
          'Nouvelle commande',
          style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
