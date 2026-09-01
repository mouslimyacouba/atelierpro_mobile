import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/fiche_mesure.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/fiches_mesures_provider.dart';
import '../../widgets/spinner.dart';

final _date = DateFormat('dd/MM/yyyy');

class MesuresScreen extends StatefulWidget {
  const MesuresScreen({super.key});

  @override
  State<MesuresScreen> createState() => _MesuresScreenState();
}

class _MesuresScreenState extends State<MesuresScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final userId = context.read<AtelierProvider>().atelier?.userId;
      if (userId != null) context.read<FichesMesuresProvider>().load(userId);
    }
  }

  Future<void> _openForm({FicheMesure? existing}) async {
    final userId = context.read<AtelierProvider>().atelier!.userId;
    final clients = context.read<ClientsProvider>().clients;
    final titreCtrl = TextEditingController(text: existing?.titre ?? 'Mesures');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String? clientId = existing?.clientId ?? (clients.isNotEmpty ? clients.first.id : null);
    final champCtrls = <String, TextEditingController>{
      for (final champ in FicheMesure.champsSuggeres)
        champ: TextEditingController(text: existing?.mesures[champ]?.toString() ?? ''),
    };
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: ListView(
              controller: scrollController,
              children: [
                Text(
                  existing == null ? 'Nouvelle fiche de mesures' : 'Modifier la fiche',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: clientId,
                  decoration: const InputDecoration(labelText: 'Client'),
                  items: clients
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nomComplet)))
                      .toList(),
                  onChanged: existing != null ? null : (v) => clientId = v,
                  validator: (v) => v == null ? 'Sélectionnez un client' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: titreCtrl,
                  decoration: const InputDecoration(labelText: 'Titre (ex: Boubou fête)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
                ),
                const SizedBox(height: 16),
                const Text('Mesures (cm)', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                for (final champ in FicheMesure.champsSuggeres)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextFormField(
                      controller: champCtrls[champ],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: champ),
                    ),
                  ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: clients.isEmpty
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final mesures = <String, dynamic>{};
                          for (final entry in champCtrls.entries) {
                            final v = entry.value.text.trim();
                            if (v.isNotEmpty) mesures[entry.key] = double.tryParse(v.replaceAll(',', '.')) ?? v;
                          }

                          String? error;
                          if (existing == null) {
                            error = await context.read<FichesMesuresProvider>().addFiche(FicheMesure(
                                  id: '',
                                  userId: userId,
                                  clientId: clientId!,
                                  titre: titreCtrl.text.trim(),
                                  mesures: mesures,
                                  notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                ));
                          } else {
                            error = await context.read<FichesMesuresProvider>().updateFiche(existing.id, {
                              'titre': titreCtrl.text.trim(),
                              'mesures': mesures,
                              'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                            });
                          }

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
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fiche enregistrée')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fichesProvider = context.watch<FichesMesuresProvider>();
    final clientsProvider = context.watch<ClientsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Fiches de mesures')),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = context.read<AtelierProvider>().atelier?.userId;
          if (userId != null) await context.read<FichesMesuresProvider>().load(userId);
        },
        child: fichesProvider.loading && fichesProvider.fiches.isEmpty
            ? ListView(children: const [SizedBox(height: 200), AtelierSpinner()])
            : fichesProvider.fiches.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('Aucune fiche de mesures')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: fichesProvider.fiches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final fiche = fichesProvider.fiches[i];
                      final client = clientsProvider.byId(fiche.clientId);
                      return Card(
                        child: ListTile(
                          onTap: () => _openForm(existing: fiche),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0x1FC0432A),
                            child: Icon(Icons.straighten, color: AtelierProColors.terracotta, size: 20),
                          ),
                          title: Text(fiche.titre),
                          subtitle: Text('${client?.nomComplet ?? 'Client'} · ${_date.format(fiche.updatedAt)}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'delete') {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Supprimer cette fiche ?'),
                                    content: const Text('Cette action est irréversible.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('Supprimer', style: TextStyle(color: AtelierProColors.rougeAlerte)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true && context.mounted) {
                                  await context.read<FichesMesuresProvider>().deleteFiche(fiche.id);
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'info',
                                enabled: false,
                                child: Text('${fiche.mesures.length} mesures',
                                    style: const TextStyle(fontSize: 12, color: Colors.black45)),
                              ),
                              const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: clientsProvider.clients.isEmpty
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ajoutez d\'abord un client')),
                )
            : () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
