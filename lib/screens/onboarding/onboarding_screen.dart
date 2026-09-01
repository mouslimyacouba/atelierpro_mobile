import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/atelier.dart';
import '../../providers/atelier_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  String _specialite = Atelier.specialiteSuggestions.first;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telephoneCtrl.dispose();
    _villeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await context.read<AtelierProvider>().createAtelier(
            nomAtelier: _nomCtrl.text.trim(),
            specialite: _specialite,
            telephone: _telephoneCtrl.text.trim().isEmpty ? null : _telephoneCtrl.text.trim(),
            ville: _villeCtrl.text.trim().isEmpty ? null : _villeCtrl.text.trim(),
          );

      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = result;
      });

      if (result != null) {
        debugPrint("Erreur création atelier: $result");
      } else {
        debugPrint("Atelier créé avec succès, redirection en cours...");
      }
    } catch (e) {
      debugPrint("Exception _submit onboarding: $e");
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtelierProColors.sable,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Créons votre atelier',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Quelques infos pour démarrer — vous pourrez tout modifier plus tard.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom de l\'atelier'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _specialite,
                  decoration: const InputDecoration(labelText: "Type d'activité"),
                  items: Atelier.specialiteSuggestions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _specialite = v ?? _specialite),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telephoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Téléphone (optionnel)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _villeCtrl,
                  decoration: const InputDecoration(labelText: 'Ville (optionnel)'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer mon atelier'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
