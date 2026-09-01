import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/contact_actions.dart';
import '../../core/theme.dart';
import '../../models/atelier.dart';
import '../../models/client.dart';
import '../../models/order.dart';
import '../../models/payment.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/spinner.dart';

final _money = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
final _date = DateFormat('dd/MM/yyyy à HH:mm');
final _dateShort = DateFormat('dd/MM/yyyy');

String _buildReceiptText({
  required Atelier? atelier,
  required AtelierClient? client,
  required AtelierOrder order,
  required List<AtelierPayment> payments,
}) {
  final buffer = StringBuffer();
  buffer.writeln('✨ *REÇU - ${atelier?.nomAtelier?.toUpperCase() ?? 'ATELIER'}* ✨');
  if (atelier?.ville != null) buffer.writeln('📍 ${atelier!.ville}');
  if (atelier?.telephone != null) buffer.writeln('📞 ${atelier!.telephone}');
  buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
  buffer.writeln('👤 *Client :* ${client?.nomComplet ?? '—'}');
  buffer.writeln('📦 *Commande :* ${order.description}');
  buffer.writeln('📅 *Date :* ${_dateShort.format(order.dateCommande)}');
  if (order.dateEcheance != null) {
    buffer.writeln('🚚 *Livraison prévue :* ${_dateShort.format(order.dateEcheance!)}');
  }
  buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
  buffer.writeln('💰 *MONTANT TOTAL :* ${_money.format(order.prixTotal)}');

  if (payments.isNotEmpty) {
    buffer.writeln('\n*Détails des paiements :*');
    for (final p in payments) {
      buffer.writeln('✅ ${_dateShort.format(p.datePaiement)} : ${_money.format(p.montant)} (${p.modeLabel})');
    }
  }

  buffer.writeln('\n━━━━━━━━━━━━━━━━━━━━');
  buffer.writeln('💵 *Déjà payé :* ${_money.format(order.acompte)}');
  buffer.writeln('📉 *Reste à payer :* *${_money.format(order.remaining)}*');
  buffer.writeln('━━━━━━━━━━━━━━━━━━━━');

  if (order.isFullyPaid) {
    buffer.writeln('\n✅ *COMMANDE SOLDÉE*');
    buffer.writeln('Merci pour votre confiance !');
  } else {
    buffer.writeln('\n🙏 Merci de votre confiance.');
  }

  return buffer.toString();
}

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<AtelierPayment> _payments = [];
  bool _loadingPayments = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _loadingPayments = true);
    final payments = await context.read<OrdersProvider>().paymentsForOrder(widget.orderId);
    if (!mounted) return;
    setState(() {
      _payments = payments;
      _loadingPayments = false;
    });
  }

  Future<void> _addPayment(AtelierOrder order) async {
    final amountCtrl = TextEditingController();
    String method = 'especes';
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Enregistrer un paiement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Reste dû : ${_money.format(order.remaining)}', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Montant reçu (FCFA)'),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                    if (n == null || n <= 0) return 'Montant invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: const InputDecoration(labelText: 'Mode de paiement'),
                  items: AtelierPayment.modeLabels.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => method = v ?? method),
                ),
                const SizedBox(height: 6),
                const Text(
                  "L'encaissement automatique par mobile money (iPayMoney) arrive dans une prochaine version. "
                  "Pour l'instant, saisissez le paiement manuellement après réception.",
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final amount = double.parse(amountCtrl.text.replaceAll(',', '.'));
                    final error = await context.read<OrdersProvider>().recordPayment(
                          orderId: order.id,
                          userId: order.userId,
                          amount: amount,
                          mode: method,
                        );
                    if (ctx.mounted) {
                      if (error != null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Erreur : $error")));
                      } else {
                        Navigator.of(ctx).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Paiement enregistré avec succès')),
                        );
                      }
                    }
                  },
                  child: const Text('Enregistrer le paiement'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true) _loadPayments();
  }

  Future<void> _shareReceipt(AtelierOrder order, AtelierClient? client) async {
    final atelier = context.read<AtelierProvider>().atelier;
    final text = _buildReceiptText(atelier: atelier, client: client, order: order, payments: _payments);
    await Share.share(text, subject: 'Reçu - ${client?.nomComplet ?? ''}');
  }

  Future<void> _sendReceiptWhatsApp(AtelierOrder order, AtelierClient? client) async {
    if (client?.telephone == null || client!.telephone!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ce client n\'a pas de numéro de téléphone enregistré')),
      );
      return;
    }
    final atelier = context.read<AtelierProvider>().atelier;
    final text = _buildReceiptText(atelier: atelier, client: client, order: order, payments: _payments);
    await openWhatsApp(client.telephone!, message: text);
  }

  Future<void> _sendPaymentReminder(AtelierOrder order, AtelierClient? client) async {
    if (client?.telephone == null || client!.telephone!.trim().isEmpty) return;
    final atelier = context.read<AtelierProvider>().atelier;
    final message =
        'Bonjour ${client.nomComplet}, un petit rappel de la part de ${atelier?.nomAtelier ?? 'notre atelier'} : '
        'il reste ${_money.format(order.remaining)} à régler pour votre commande "${order.description}". '
        'Merci de votre confiance 🙏';
    await openWhatsApp(client.telephone!, message: message);
  }

  Future<void> _sendDeliveryReminder(AtelierOrder order, AtelierClient? client) async {
    if (client?.telephone == null || client!.telephone!.trim().isEmpty || order.dateEcheance == null) return;
    final atelier = context.read<AtelierProvider>().atelier;
    final message =
        'Bonjour ${client.nomComplet}, votre commande "${order.description}" chez '
        '${atelier?.nomAtelier ?? 'notre atelier'} est prévue le ${_dateShort.format(order.dateEcheance!)}. '
        'On vous tient au courant !';
    await openWhatsApp(client.telephone!, message: message);
  }

  Future<void> _editOrder(AtelierOrder order) async {
    final descCtrl = TextEditingController(text: order.description);
    final amountCtrl = TextEditingController(text: order.prixTotal.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Modifier la commande', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description requise' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Montant total (FCFA)'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Montant invalide';
                  if (n < order.acompte) {
                    return 'Doit être ≥ au montant déjà payé (${order.acompte.toStringAsFixed(0)})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final error = await context.read<OrdersProvider>().updateOrder(
                        order.id,
                        description: descCtrl.text.trim(),
                        prixTotal: double.parse(amountCtrl.text.replaceAll(',', '.')),
                      );
                  if (ctx.mounted) {
                    if (error != null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      Navigator.of(ctx).pop(true);
                    }
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commande mise à jour')));
    }
  }

  Future<void> _confirmDeleteOrder(AtelierOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette commande ?'),
        content: const Text('Les paiements associés seront également supprimés. Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: AtelierProColors.rougeAlerte)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final error = await context.read<OrdersProvider>().deleteOrder(order.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      context.go('/commandes');
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersProvider>().byId(widget.orderId);
    final client = order == null ? null : context.watch<ClientsProvider>().byId(order.clientId);

    if (order == null) {
      return const Scaffold(body: AtelierSpinner());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(client?.nomComplet ?? 'Commande'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _editOrder(order)),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDeleteOrder(order)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _AmountBlock(label: 'Total', value: _money.format(order.prixTotal)),
                      _AmountBlock(label: 'Payé', value: _money.format(order.acompte), color: AtelierProColors.vertSucces),
                      _AmountBlock(label: 'Reste', value: _money.format(order.remaining), color: AtelierProColors.orangeAttente),
                    ],
                  ),
                  if (order.dateEcheance != null) ...[
                    const SizedBox(height: 12),
                    Text('Livraison prévue : ${DateFormat('dd/MM/yyyy').format(order.dateEcheance!)}',
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _shareReceipt(order, client),
                icon: const Icon(Icons.share_outlined, size: 16),
                label: const Text('Partager le reçu'),
              ),
              OutlinedButton.icon(
                onPressed: () => _sendReceiptWhatsApp(order, client),
                icon: const Icon(Icons.share, size: 16, color: Color(0xFF25D366)),
                label: const Text('Reçu WhatsApp', style: TextStyle(color: Color(0xFF25D366))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF25D366)),
                ),
              ),
              if (!order.isFullyPaid)
                OutlinedButton.icon(
                  onPressed: () => _sendPaymentReminder(order, client),
                  icon: const Icon(Icons.notifications_active_outlined, size: 16, color: AtelierProColors.orangeAttente),
                  label: const Text('Rappel paiement'),
                ),
              if (order.dateEcheance != null)
                OutlinedButton.icon(
                  onPressed: () => _sendDeliveryReminder(order, client),
                  icon: const Icon(Icons.local_shipping_outlined, size: 16),
                  label: const Text('Rappel livraison'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Statut', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in OrderStatus.values)
                ChoiceChip(
                  label: Text(status.label),
                  selected: order.status == status,
                  onSelected: (_) => context.read<OrdersProvider>().updateStatus(order.id, status),
                  selectedColor: status.color.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: order.status == status ? status.color : Colors.black87,
                    fontWeight: order.status == status ? FontWeight.w700 : FontWeight.w400,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: order.status == status ? status.color : Colors.black12),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Paiements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if (!order.isFullyPaid)
                TextButton.icon(
                  onPressed: () => _addPayment(order),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                ),
            ],
          ),
          if (_loadingPayments)
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: AtelierSpinner())
          else if (_payments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('Aucun paiement enregistré')),
            )
          else
            for (final p in _payments)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: AtelierProColors.vertSucces),
                  title: Text(_money.format(p.montant)),
                  subtitle: Text('${p.modeLabel} · ${_date.format(p.datePaiement)}'),
                ),
              ),
        ],
      ),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _AmountBlock({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
