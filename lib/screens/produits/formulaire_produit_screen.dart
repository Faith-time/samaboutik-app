import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/produit.dart';
import '../../providers/produit_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/champ_texte.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';

/// Ajout ou modification d'un produit (si [produit] est fourni).
class FormulaireProduitScreen extends StatefulWidget {
  final Produit? produit;
  const FormulaireProduitScreen({super.key, this.produit});

  @override
  State<FormulaireProduitScreen> createState() =>
      _FormulaireProduitScreenState();
}

class _FormulaireProduitScreenState extends State<FormulaireProduitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _prix;
  late final TextEditingController _cout;
  late bool _actif;

  @override
  void initState() {
    super.initState();
    final p = widget.produit;
    _nom = TextEditingController(text: p?.nom ?? '');
    _prix = TextEditingController(text: p == null ? '' : '${p.prixFcfa}');
    _cout = TextEditingController(text: p?.coutFcfa == null ? '' : '${p!.coutFcfa}');
    _actif = p?.actif ?? true;
  }

  @override
  void dispose() {
    _nom.dispose();
    _prix.dispose();
    _cout.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ProduitProvider>();
    final ok = await provider.enregistrer(
      existant: widget.produit,
      nom: _nom.text.trim(),
      prix: int.parse(_prix.text),
      cout: _cout.text.isEmpty ? null : int.parse(_cout.text),
      actif: _actif,
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProduitProvider>();
    final modification = widget.produit != null;
    return EcranNeo(
      titre: modification ? 'Modifier le produit' : 'Nouveau produit',
      retour: true,
      defiler: true,
      bas: BoutonPrincipal(
        texte: 'Enregistrer',
        chargement: provider.chargement,
        onPressed: _enregistrer,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 8),
            ChampTexte(
              controller: _nom,
              label: 'Nom du produit',
              icone: Icons.inventory_2_outlined,
              action: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Donnez un nom au produit'
                  : null,
            ),
            const SizedBox(height: 14),
            ChampTexte(
              controller: _prix,
              label: 'Prix de vente',
              icone: Icons.sell_outlined,
              suffixe: 'FCFA',
              clavier: TextInputType.number,
              formatteurs: [FilteringTextInputFormatter.digitsOnly],
              action: TextInputAction.next,
              validator: (v) => (v == null || v.isEmpty || int.parse(v) <= 0)
                  ? 'Saisissez un prix'
                  : null,
            ),
            const SizedBox(height: 14),
            ChampTexte(
              controller: _cout,
              label: "Prix d'achat (facultatif)",
              icone: Icons.shopping_basket_outlined,
              suffixe: 'FCFA',
              clavier: TextInputType.number,
              formatteurs: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  "Le prix d'achat sert à estimer votre bénéfice.",
                  style: Typo.petit,
                ),
              ),
            ),
            if (modification) ...[
              const SizedBox(height: 18),
              CarteNeo(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                rayon: 20,
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Produit actif', style: Typo.sousTitre),
                  subtitle: const Text(
                      'Un produit désactivé n\'apparaît plus dans les ventes.',
                      style: Typo.petit),
                  value: _actif,
                  onChanged: (v) => setState(() => _actif = v),
                ),
              ),
            ],
            if (provider.erreur != null) ...[
              const SizedBox(height: 16),
              MessageErreur(message: provider.erreur!),
            ],
          ],
        ),
      ),
    );
  }
}
