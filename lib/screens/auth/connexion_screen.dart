import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/champ_texte.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import 'inscription_screen.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  static const _cleTelephone = 'telephone_memorise';

  final _formKey = GlobalKey<FormState>();
  final _telephone = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _souvenir = true;

  @override
  void initState() {
    super.initState();
    _chargerSouvenir();
  }

  @override
  void dispose() {
    _telephone.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  // « Se souvenir de moi » : on garde seulement le numéro de téléphone
  Future<void> _chargerSouvenir() async {
    final prefs = await SharedPreferences.getInstance();
    final tel = prefs.getString(_cleTelephone);
    if (tel != null && mounted) setState(() => _telephone.text = tel);
  }

  Future<void> _memoriser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_souvenir) {
      await prefs.setString(_cleTelephone, _telephone.text.trim());
    } else {
      await prefs.remove(_cleTelephone);
    }
  }

  Future<void> _valider() async {
    if (!_formKey.currentState!.validate()) return;
    await _memoriser();
    if (!mounted) return;
    // En cas de succès, app.dart affiche tout seul l'accueil
    await context
        .read<AuthProvider>()
        .connexion(_telephone.text.trim(), _motDePasse.text);
  }

  void _motDePasseOublie() => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Mot de passe oublié'),
      content: const Text(
          'La réinitialisation du mot de passe sera bientôt disponible.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Compris'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Couleurs.fondHaut,
      body: FondNeo(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset('assets/images/logo_icone.png',
                        height: 84),
                  ),
                  const SizedBox(height: 6),
                  const Text('SamaBoutik',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Couleurs.texte)),
                  const SizedBox(height: 2),
                  const Text('Votre boutique, plus connectée',
                      textAlign: TextAlign.center, style: Typo.petit),
                  const SizedBox(height: 26),
                  const Text('Connexion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Couleurs.texte)),
                  const SizedBox(height: 2),
                  const Text('Accédez à votre espace commerçant',
                      textAlign: TextAlign.center, style: Typo.petit),
                  const SizedBox(height: 22),
                  ChampTexte(
                    controller: _telephone,
                    label: 'Numéro de téléphone',
                    icone: Icons.phone_outlined,
                    clavier: TextInputType.phone,
                    action: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Saisissez votre téléphone'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  ChampTexte(
                    controller: _motDePasse,
                    label: 'Mot de passe',
                    icone: Icons.lock_outline_rounded,
                    motDePasse: true,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Saisissez votre mot de passe'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _souvenir = !_souvenir),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _souvenir
                                    ? Couleurs.bleu
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: _souvenir
                                        ? Couleurs.bleu
                                        : Couleurs.ligne,
                                    width: 1.5),
                              ),
                              child: _souvenir
                                  ? const Icon(Icons.check_rounded,
                                  size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Text('Se souvenir de moi',
                                style: TextStyle(
                                    fontSize: 12.5, color: Couleurs.texte)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _motDePasseOublie,
                        child: const Text('Mot de passe oublié ?',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Couleurs.bleu)),
                      ),
                    ],
                  ),
                  if (auth.erreur != null) ...[
                    const SizedBox(height: 16),
                    MessageErreur(message: auth.erreur!),
                  ],
                  const SizedBox(height: 20),
                  BoutonPrincipal(
                    texte: 'Se connecter',
                    chargement: auth.chargement,
                    onPressed: _valider,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pas encore de compte ? ', style: Typo.petit),
                      GestureDetector(
                        onTap: () => aller(context, const InscriptionScreen()),
                        child: const Text("S'inscrire",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Couleurs.bleu)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}