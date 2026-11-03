import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../providers/produit_provider.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/champ_texte.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';

/// Une ligne d'achat : un produit, des paquets, un prix.
class _LigneAchat {
  static int _compteur = 0;
  final int cle = _compteur++;
  int? produitId;
  final nbLots = TextEditingController(text: '1');
  final unites = TextEditingController(text: '1');
  final prix = TextEditingController();

  int get nbLotsInt => int.tryParse(nbLots.text) ?? 0;
  int get unitesInt => int.tryParse(unites.text) ?? 0;
  int get prixInt => int.tryParse(prix.text) ?? 0;
  int get totalUnites => nbLotsInt * unitesInt;
  int get depense => nbLotsInt * prixInt;
  double get coutUnitaire => unitesInt > 0 ? prixInt / unitesInt : 0;

  void dispose() {
    nbLots.dispose();
    unites.dispose();
    prix.dispose();
  }
}

/// Enregistrer ce qu'on a acheté chez le fournisseur.
/// Exemple : 4 paquets de 24 biscuits à 2 400 FCFA le paquet.
class ReapprovisionnerScreen extends StatefulWidget {
  final int? produitId;
  const ReapprovisionnerScreen({super.key, this.produitId});

  @override
  State<ReapprovisionnerScreen> createState() => _ReapprovisionnerScreenState();
}

class _ReapprovisionnerScreenState extends State<ReapprovisionnerScreen> {
  final _lignes = <_LigneAchat>[];
  final _fournisseur = TextEditingController();
  bool _envoi = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _ajouterLigne();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final s = context.read<StockProvider>();
      if (s.donnees == null) await s.charger();
      if (!mounted) return;
      if (widget.produitId != null) _choisir(_lignes.first, widget.produitId);
    });
  }

  @override
  void dispose() {
    _fournisseur.dispose();
    for (final l in _lignes) {
      l.dispose();
    }
    super.dispose();
  }

  void _maj() {
    if (mounted) setState(() {});
  }

  void _ajouterLigne() {
    final l = _LigneAchat();
    l.nbLots.addListener(_maj);
    l.unites.addListener(_maj);
    l.prix.addListener(_maj);
    _lignes.add(l);
  }

  void _choisir(_LigneAchat l, int? id) {
    final p = id == null ? null : context.read<StockProvider>().produit(id);
    setState(() {
      l.produitId = id;
      if (p != null) {
        l.unites.text = '${p.unitesParLot}';
        if (p.coutMoyenFcfa != null && l.prix.text.isEmpty) {
          l.prix.text = (p.coutMoyenFcfa! * p.unitesParLot).round().toString();
        }
      }
    });
  }

  int get _depenseTotale => _lignes.fold(0, (s, l) => s + l.depense);

  Future<void> _enregistrer() async {
    for (final l in _lignes) {
      if (l.produitId == null) {
        setState(() => _erreur = 'Choisissez le produit de chaque ligne.');
        return;
      }
      if (l.nbLotsInt <= 0 || l.unitesInt <= 0 || l.prixInt <= 0) {
        setState(() => _erreur =
            "Renseignez le nombre de paquets, les unités par paquet et le prix d'un paquet.");
        return;
      }
    }
    setState(() {
      _erreur = null;
      _envoi = true;
    });

    final stock = context.read<StockProvider>();
    final produits = context.read<ProduitProvider>();
    final ok = await stock.enregistrerAchat(
      fournisseur: _fournisseur.text,
      lignes: [
        for (final l in _lignes)
          {
            'produit_id': l.produitId,
            'nb_lots': l.nbLotsInt,
            'unites_par_lot': l.unitesInt,
            'prix_lot_fcfa': l.prixInt,
          },
      ],
    );
    if (!mounted) return;
    setState(() => _envoi = false);

    if (ok) {
      produits.charger();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Achat enregistré. Stock mis à jour.')));
      Navigator.of(context).pop();
    } else {
      setState(() => _erreur = stock.erreurAction ?? 'Une erreur est survenue.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<StockProvider>();
    final produits = s.donnees?.produits ?? const [];

    return EcranNeo(
      titre: 'Réapprovisionner',
      retour: true,
      defiler: true,
      bas: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: [
                const Expanded(child: Text('Dépense totale', style: Typo.doux)),
                Text(formatFcfa(_depenseTotale), style: Typo.montant),
              ],
            ),
          ),
          BoutonPrincipal(
            texte: "Enregistrer l'achat",
            icone: Icons.check_rounded,
            chargement: _envoi,
            onPressed: _enregistrer,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notez ce que vous avez acheté chez votre fournisseur. '
            'Le stock et le coût de revient sont mis à jour automatiquement.',
            style: Typo.doux,
          ),
          const SizedBox(height: 16),
          ChampTexte(
            controller: _fournisseur,
            label: 'Fournisseur (facultatif)',
            icone: Icons.storefront_outlined,
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _lignes.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _carteLigne(i, _lignes[i], produits),
            ),
          BoutonPrincipal(
            texte: 'Ajouter un autre produit',
            secondaire: true,
            icone: Icons.add_rounded,
            onPressed: () => setState(_ajouterLigne),
          ),
          if (_erreur != null) ...[
            const SizedBox(height: 14),
            Text(_erreur!, style: const TextStyle(color: Couleurs.erreur)),
          ],
        ],
      ),
    );
  }

  Widget _carteLigne(int index, _LigneAchat l, List produits) {
    final resume = (l.totalUnites > 0 && l.prixInt > 0)
        ? '= ${l.totalUnites} unités · ${formatFcfa(l.coutUnitaire.round())} l\'unité · ${formatFcfa(l.depense)}'
        : null;

    return CarteNeo(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Produit ${index + 1}', style: Typo.sousTitre)),
              if (_lignes.length > 1)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, color: Couleurs.texteDoux),
                  onPressed: () => setState(() {
                    _lignes.removeAt(index).dispose();
                  }),
                ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            key: ValueKey('produit-${l.cle}-${l.produitId}'),
            initialValue: l.produitId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Produit'),
            items: [
              for (final p in produits)
                DropdownMenuItem<int>(
                  value: p.produitId as int,
                  child: Text(p.nom as String, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => _choisir(l, v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChampTexte(
                  controller: l.nbLots,
                  label: 'Paquets achetés',
                  clavier: TextInputType.number,
                  formatteurs: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChampTexte(
                  controller: l.unites,
                  label: 'Unités / paquet',
                  clavier: TextInputType.number,
                  formatteurs: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ChampTexte(
            controller: l.prix,
            label: "Prix d'un paquet",
            icone: Icons.sell_outlined,
            suffixe: 'FCFA',
            clavier: TextInputType.number,
            formatteurs: [FilteringTextInputFormatter.digitsOnly],
          ),
          if (resume != null) ...[
            const SizedBox(height: 10),
            Text(resume, style: Typo.petit),
          ],
        ],
      ),
    );
  }
}
