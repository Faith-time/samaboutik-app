import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/champ_texte.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _telephone = TextEditingController();
  final _nomBoutique = TextEditingController();
  final _motDePasse = TextEditingController();

  @override
  void dispose() {
    _nom.dispose();
    _telephone.dispose();
    _nomBoutique.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  String? _obligatoire(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Ce champ est obligatoire' : null;

  Future<void> _valider() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().inscription(
      nom: _nom.text.trim(),
      telephone: _telephone.text.trim(),
      motDePasse: _motDePasse.text,
      nomBoutique: _nomBoutique.text.trim(),
    );
    // On revient à la racine : app.dart montre alors l'accueil
    if (ok && mounted) retourAccueil(context);
  }

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
                  const Text('Créer un compte',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Couleurs.texte)),
                  const SizedBox(height: 2),
                  const Text('Ouvrez votre espace commerçant',
                      textAlign: TextAlign.center, style: Typo.petit),
                  const SizedBox(height: 22),
                  ChampTexte(
                    controller: _nom,
                    label: 'Votre nom',
                    icone: Icons.person_outline_rounded,
                    action: TextInputAction.next,
                    validator: _obligatoire,
                  ),
                  const SizedBox(height: 14),
                  ChampTexte(
                    controller: _telephone,
                    label: 'Numéro de téléphone',
                    icone: Icons.phone_outlined,
                    clavier: TextInputType.phone,
                    action: TextInputAction.next,
                    validator: _obligatoire,
                  ),
                  const SizedBox(height: 14),
                  ChampTexte(
                    controller: _nomBoutique,
                    label: 'Nom de la boutique',
                    icone: Icons.storefront_outlined,
                    action: TextInputAction.next,
                    validator: _obligatoire,
                  ),
                  const SizedBox(height: 14),
                  ChampTexte(
                    controller: _motDePasse,
                    label: 'Mot de passe (6 caractères minimum)',
                    icone: Icons.lock_outline_rounded,
                    motDePasse: true,
                    validator: (v) => (v == null || v.length < 6)
                        ? '6 caractères minimum'
                        : null,
                  ),
                  if (auth.erreur != null) ...[
                    const SizedBox(height: 16),
                    MessageErreur(message: auth.erreur!),
                  ],
                  const SizedBox(height: 20),
                  BoutonPrincipal(
                    texte: 'Créer mon compte',
                    chargement: auth.chargement,
                    onPressed: _valider,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Déjà un compte ? ', style: Typo.petit),
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Text('Se connecter',
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