import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final result = _isSignUp
        ? await auth.signUp(email: _emailCtrl.text.trim(), password: _passwordCtrl.text)
        : await auth.signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = result;
    });

    if (result == null && _isSignUp) {
      setState(() {
        _isSignUp = false;
        _passwordCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé ! Un e-mail de confirmation vous a été envoyé. Veuillez vous connecter après avoir vérifié votre boîte de réception.'),
          duration: Duration(seconds: 8),
          backgroundColor: AtelierProColors.vertSucces,
        ),
      );
    }
  }

  Future<void> _submitGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final result = await auth.signInWithGoogle();

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = result;
    });

    if (result == null && _isSignUp) {
      setState(() {
        _isSignUp = false;
        _passwordCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé ! Un e-mail de confirmation vous a été envoyé. Veuillez vous connecter après avoir vérifié votre boîte de réception.'),
          duration: Duration(seconds: 8),
          backgroundColor: AtelierProColors.vertSucces,
        ),
      );
    }
  }

  Future<void> _forgotPassword() async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    final formKey = GlobalKey<FormState>();
    bool sending = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Mot de passe oublié', style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Un lien de réinitialisation vous sera envoyé par e-mail.',
                  style: TextStyle(fontSize: 13, color: AtelierProColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
            TextButton(
              onPressed: sending
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => sending = true);
                      final error = await context
                          .read<AuthProvider>()
                          .resetPasswordForEmail(emailCtrl.text.trim());
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(error ?? 'E-mail envoyé — vérifie ta boîte de réception.'),
                          ),
                        );
                      }
                    },
              child: sending
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtelierProColors.surfaceTan,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AtelierProColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AtelierProColors.outlineVariant, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Badge Icône Stitch (Brown Icon Box)
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AtelierProColors.primary,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AtelierProColors.surfaceContainerLowest, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: AtelierProColors.primary.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.content_cut_outlined, size: 36, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // En-tête Titre & Soustitre
                      Text(
                        'Atelier Niger',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AtelierProColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSignUp ? 'Créer un compte' : 'Bienvenue',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AtelierProColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSignUp
                            ? 'Inscrivez-vous pour gérer votre atelier'
                            : 'Connectez-vous pour gérer votre atelier',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 15,
                          color: AtelierProColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Champ EMAIL
                      Text(
                        'EMAIL',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AtelierProColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'artisan@atelier.ne',
                          prefixIcon: Icon(Icons.email_outlined, size: 20, color: AtelierProColors.outline),
                        ),
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Email invalide' : null,
                      ),
                      const SizedBox(height: 16),

                      // Champ MOT DE PASSE
                      Text(
                        'MOT DE PASSE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AtelierProColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AtelierProColors.outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                              color: AtelierProColors.outline,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.length < 6) ? 'Minimum 6 caractères' : null,
                      ),

                      if (!_isSignUp) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Mot de passe oublié ?',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: AtelierProColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],

                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AtelierProColors.rougeAlerte.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AtelierProColors.rougeAlerte.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, size: 18, color: AtelierProColors.rougeAlerte),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: GoogleFonts.sourceSans3(
                                    fontSize: 13,
                                    color: AtelierProColors.rougeAlerte,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Bouton principal Se Connecter / S'inscrire
                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AtelierProColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isSignUp ? "S'inscrire" : 'Se connecter',
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Divider OU
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OU',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 13,
                                color: AtelierProColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bouton Google
                      OutlinedButton(
                        onPressed: _loading ? null : _submitGoogle,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: AtelierProColors.outlineVariant),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                              height: 20,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.g_mobiledata, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Continuer avec Google',
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AtelierProColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bouton bascule Inscription / Connexion
                      Center(
                        child: GestureDetector(
                          onTap: () => setState(() => _isSignUp = !_isSignUp),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.sourceSans3(
                                fontSize: 15,
                                color: AtelierProColors.onSurfaceVariant,
                              ),
                              children: [
                                TextSpan(
                                  text: _isSignUp
                                      ? 'Déjà un compte ? '
                                      : 'Pas encore de compte ? ',
                                ),
                                TextSpan(
                                  text: _isSignUp ? 'Se connecter' : "S'inscrire",
                                  style: GoogleFonts.sourceSans3(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AtelierProColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
