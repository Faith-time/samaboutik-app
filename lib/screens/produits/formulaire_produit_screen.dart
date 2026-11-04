import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/stock_outils.dart';
import '../../core/theme.dart';
import '../../models/produit.dart';
import '../../providers/produit_provider.dart';
import '../../providers/stock_provider.dart';
import '../../services/api_client.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/champ_texte.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/selecteur_image_produit.dart';
import '../stock/reapprovisionner_screen.dart';

/// Ajout ou modification d'un produit (si [produit] est fourni), avec le suivi du stock.
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
  final _unites = TextEditingController(text: '1');
  final _stockDepart = TextEditingController();
  final _seuil = TextEditingController();
  late final String _coutInitial;
  late bool _actif;
  bool _suivre = false;
  bool _envoi = false;
  String? _erreur;

  // Photo : nouvelle image choisie (chemin local) ou retrait de l'image existante
  String? _imageLocale;
  bool _imageRetiree = false;

  // Stock actuel (modification d'un produit déjà suivi)
  int? _stockActuel;
  double? _lotsRestants;

  bool get _modification => widget.produit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.produit;
    _nom = TextEditingController(text: p?.nom ?? '');
    _prix = TextEditingController(text: p == null ? '' : '${p.prixFcfa}');
    _coutInitial = p?.coutFcfa == null ? '' : '${p!.coutFcfa}';
    _cout = TextEditingController(text: _coutInitial);
    _actif = p?.actif ?? true;

    if (p != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final s = context.read<StockProvider>();
        if (s.donnees == null) await s.charger();
        if (!mounted) return;
        final sp = s.produit(p.id);
        if (sp != null) {
          setState(() {
            _suivre = sp.suivreStock;
            _unites.text = '${sp.unitesParLot}';
            _seuil.text = sp.seuilAlerte?.toString() ?? '';
            _stockActuel = sp.stockActuel;
            _lotsRestants = sp.lotsRestants;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nom.dispose();
    _prix.dispose();
    _cout.dispose();
    _unites.dispose();
    _stockDepart.dispose();
    _seuil.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _envoi = true;
      _erreur = null;
    });

    final champs = <String, dynamic>{
      'nom': _nom.text.trim(),
      'prix_fcfa': int.parse(_prix.text),
      'actif': _actif,
      'suivre_stock': _suivre,
    };
    // Le prix d'achat n'est envoyé que s'il a été modifié (sinon on garde le coût moyen exact)
    if (_cout.text != _coutInitial) {
      champs['cout_fcfa'] = _cout.text.isEmpty ? null : int.parse(_cout.text);
    }
    if (_suivre) {
      champs['unites_par_lot'] = int.tryParse(_unites.text) ?? 1;
      champs['seuil_alerte'] = _seuil.text.isEmpty ? null : int.parse(_seuil.text);
      if (!_modification && _stockDepart.text.isNotEmpty) {
        champs['stock_initial'] = int.parse(_stockDepart.text);
      }
    }

    final stock = context.read<StockProvider>();
    final produits = context.read<ProduitProvider>();
    final messager = ScaffoldMessenger.of(context);
    final navigateur = Navigator.of(context);
    try {
      final id = await stock.enregistrerProduit(id: widget.produit?.id, champs: champs);

      // La photo est envoyée à part. Si elle échoue, le produit est quand même enregistré
      // (on ne bloque pas le commerçant, et on évite de créer un doublon en réessayant).
      String? avertissement;
      try {
        if (_imageLocale != null) {
          await produits.televerserImage(id, _imageLocale!);
        } else if (_imageRetiree && widget.produit?.imageUrl != null) {
          await produits.supprimerImage(id);
        }
      } catch (e) {
        avertissement = "Produit enregistré, mais la photo n'a pas pu être envoyée : "
            '${ApiClient.messageErreur(e)} Réessayez en modifiant le produit.';
      }

      await Future.wait([produits.charger(), stock.charger()]);
      if (!mounted) return;
      navigateur.pop();
      if (avertissement != null) {
        messager.showSnackBar(SnackBar(content: Text(avertissement)));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _envoi = false;
          _erreur = ApiClient.messageErreur(e);
        });
      }
    }
  }

  Future<void> _corriger() async {
    final ctrl = TextEditingController(text: '${_stockActuel ?? 0}');
    final stock = context.read<StockProvider>();
    final valeur = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Corriger le stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Comptez ce qu\'il reste vraiment en rayon et saisissez le nombre d\'unités.',
              style: Typo.doux,
            ),
            const SizedBox(height: 14),
            ChampTexte(
              controller: ctrl,
              label: 'Stock réel (unités)',
              clavier: TextInputType.number,
              formatteurs: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(int.tryParse(ctrl.text)),
            child: const Text('Corriger'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (valeur == null || widget.produit == null) return;
    final ok = await stock.corriger(widget.produit!.id, valeur);
    if (!mounted) return;
    if (ok) {
      final sp = stock.produit(widget.produit!.id);
      setState(() {
        _stockActuel = sp?.stockActuel ?? valeur;
        _lotsRestants = sp?.lotsRestants;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(stock.erreurAction ?? 'Une erreur est survenue.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitesParLot = int.tryParse(_unites.text) ?? 1;

    return EcranNeo(
      titre: _modification ? 'Modifier le produit' : 'Nouveau produit',
      retour: true,
      defiler: true,
      bas: BoutonPrincipal(
        texte: 'Enregistrer',
        chargement: _envoi,
        onPressed: _enregistrer,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 8),
            SelecteurImageProduit(
              urlActuelle: _imageRetiree ? null : widget.produit?.imageUrl,
              cheminLocal: _imageLocale,
              onChoisie: (chemin) => setState(() {
                _imageLocale = chemin;
                _imageRetiree = false;
              }),
              onRetirer: () => setState(() {
                _imageLocale = null;
                _imageRetiree = true;
              }),
            ),
            const SizedBox(height: 14),
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
              label: 'Prix de vente (une unité)',
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
              label: "Prix d'achat (une unité, facultatif)",
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
                  "Sert à calculer votre bénéfice. Il est mis à jour automatiquement à chaque achat enregistré.",
                  style: Typo.petit,
                ),
              ),
            ),
            const SizedBox(height: 18),
            CarteNeo(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              rayon: 20,
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Suivre le stock', style: Typo.sousTitre),
                subtitle: const Text(
                    'Le stock baisse à chaque vente payée et vous êtes alerté avant la rupture.',
                    style: Typo.petit),
                value: _suivre,
                onChanged: (v) => setState(() => _suivre = v),
              ),
            ),
            if (_suivre) ...[
              const SizedBox(height: 14),
              ChampTexte(
                controller: _unites,
                label: 'Unités par paquet (ex. 24 biscuits)',
                icone: Icons.widgets_outlined,
                clavier: TextInputType.number,
                formatteurs: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v == null || v.isEmpty || int.parse(v) < 1)
                    ? 'Au moins 1'
                    : null,
              ),
              if (!_modification) ...[
                const SizedBox(height: 14),
                ChampTexte(
                  controller: _stockDepart,
                  label: 'Stock de départ (unités, facultatif)',
                  icone: Icons.inventory_outlined,
                  clavier: TextInputType.number,
                  formatteurs: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
              const SizedBox(height: 14),
              ChampTexte(
                controller: _seuil,
                label: "Seuil d'alerte en unités (facultatif)",
                icone: Icons.notifications_active_outlined,
                clavier: TextInputType.number,
                formatteurs: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    "Sans seuil, l'alerte se déclenche quand il reste 1 paquet ($unitesParLot unité${unitesParLot > 1 ? 's' : ''}) ou moins.",
                    style: Typo.petit,
                  ),
                ),
              ),
            ],
            if (_modification && _suivre && _stockActuel != null) ...[
              const SizedBox(height: 18),
              CarteNeo(
                rayon: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock actuel : ${texteUnites(_stockActuel!)}',
                        style: Typo.sousTitre),
                    if (_lotsRestants != null && unitesParLot > 1)
                      Text('≈ ${texteLots(_lotsRestants!)}', style: Typo.doux),
                    const SizedBox(height: 14),
                    BoutonPrincipal(
                      texte: 'Réapprovisionner',
                      icone: Icons.add_shopping_cart_rounded,
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              ReapprovisionnerScreen(produitId: widget.produit!.id))),
                    ),
                    const SizedBox(height: 10),
                    BoutonPrincipal(
                      texte: 'Corriger le stock (inventaire)',
                      secondaire: true,
                      onPressed: _corriger,
                    ),
                  ],
                ),
              ),
            ],
            if (_modification) ...[
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
            if (_erreur != null) ...[
              const SizedBox(height: 16),
              Text(_erreur!, style: const TextStyle(color: Couleurs.erreur)),
            ],
          ],
        ),
      ),
    );
  }
}
