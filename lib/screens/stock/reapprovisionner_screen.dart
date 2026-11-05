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
import '../../widgets/fond_neo.dart';
import '../../widgets/image_produit.dart';

const _vert = Color(0xFF22A06B);
const _fondEtape = Color(0xFFF4F7FE);
const _bordureEtape = Color(0xFFE3EAF8);

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
        // On remplace toujours les valeurs : chaque produit a son paquet et son prix
        l.nbLots.text = '1';
        l.unites.text = '${p.unitesParLot}';
        l.prix.text = p.coutMoyenFcfa != null
            ? (p.coutMoyenFcfa! * p.unitesParLot).round().toString()
            : '';
      }
    });
  }

  int get _depenseTotale => _lignes.fold(0, (s, l) => s + l.depense);

  /// Nom du produit choisi, pour personnaliser les questions.
  String? _nomProduit(_LigneAchat l) {
    final id = l.produitId;
    if (id == null) return null;
    final p = context.read<StockProvider>().produit(id);
    return p == null ? null : p.nom as String;
  }

  void _changerNbLots(_LigneAchat l, int delta) {
    final n = (l.nbLotsInt + delta).clamp(1, 99999).toInt();
    l.nbLots.text = '$n';
  }

  Future<void> _enregistrer() async {
    for (var i = 0; i < _lignes.length; i++) {
      final l = _lignes[i];
      final quand = _lignes.length > 1 ? ' (produit ${i + 1})' : '';
      if (l.produitId == null) {
        setState(() => _erreur = 'Choisissez le produit que vous avez acheté$quand.');
        return;
      }
      if (l.nbLotsInt <= 0) {
        setState(() => _erreur = "Indiquez combien de paquets vous avez achetés$quand.");
        return;
      }
      if (l.unitesInt <= 0) {
        setState(() => _erreur = "Indiquez combien d'articles il y a dans 1 paquet$quand.");
        return;
      }
      if (l.prixInt <= 0) {
        setState(() => _erreur = "Indiquez combien vous avez payé pour 1 paquet$quand.");
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
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text('Total dépensé', style: Typo.doux),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    formatFcfa(_depenseTotale),
                    key: ValueKey(_depenseTotale),
                    style: Typo.montant,
                  ),
                ),
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
          const _CarteAccueil(),
          const SizedBox(height: 24),
          const _TitreBloc(icone: Icons.storefront_outlined, texte: 'Votre fournisseur'),
          const SizedBox(height: 12),
          CarteNeo(
            rayon: 22,
            padding: const EdgeInsets.all(16),
            child: ChampTexte(
              controller: _fournisseur,
              label: 'Nom du fournisseur (facultatif)',
              icone: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 28),
          const _TitreBloc(icone: Icons.shopping_basket_outlined, texte: 'Ce que vous avez acheté'),
          const SizedBox(height: 12),
          for (var i = 0; i < _lignes.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _carteLigne(i, _lignes[i], produits),
            ),
          BoutonPrincipal(
            texte: 'Ajouter un autre produit acheté',
            secondaire: true,
            icone: Icons.add_rounded,
            onPressed: () => setState(_ajouterLigne),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _erreur == null
                ? const SizedBox(width: double.infinity)
                : Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _BoiteErreur(message: _erreur!),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _carteLigne(int index, _LigneAchat l, List produits) {
    final nom = _nomProduit(l);
    final pret = l.totalUnites > 0 && l.prixInt > 0;

    return CarteNeo(
      rayon: 26,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- En-tête de la carte
          Row(
            children: [
              VignetteProduit(
                produitId: l.produitId,
                taille: 44,
                repli: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3ECFF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Couleurs.bleu,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _lignes.length > 1 ? 'Produit acheté n°${index + 1}' : 'Produit acheté',
                      style: Typo.sousTitre,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nom ?? 'Pas encore choisi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Typo.petit,
                    ),
                  ],
                ),
              ),
              if (_lignes.length > 1)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Retirer ce produit',
                  icon: const Icon(Icons.delete_outline_rounded, color: Couleurs.texteDoux),
                  onPressed: () => setState(() {
                    _lignes.removeAt(index).dispose();
                  }),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // ---- Étape 1 : produit
          _Etape(
            numero: 1,
            icone: Icons.inventory_2_outlined,
            fait: l.produitId != null,
            question: 'Quel produit avez-vous acheté ?',
            child: DropdownButtonFormField<int>(
              key: ValueKey('produit-${l.cle}-${l.produitId}'),
              initialValue: l.produitId,
              isExpanded: true,
              decoration: const InputDecoration(hintText: 'Touchez pour choisir'),
              items: [
                for (final p in produits)
                  DropdownMenuItem<int>(
                    value: p.produitId as int,
                    child: Row(
                      children: [
                        VignetteProduit(
                          produitId: p.produitId as int,
                          taille: 30,
                          repli: const Icon(Icons.inventory_2_outlined,
                              size: 20, color: Couleurs.texteDoux),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(p.nom as String,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => _choisir(l, v),
            ),
          ),
          const SizedBox(height: 14),

          // ---- Étape 2 : nombre de paquets
          _Etape(
            numero: 2,
            icone: Icons.all_inbox_outlined,
            fait: l.nbLotsInt > 0,
            question: 'Combien de paquets avez-vous achetés ?',
            aide: 'Un paquet = ce que le fournisseur vous vend en une fois '
                '(carton, sachet, caisse, sac…).',
            child: Row(
              children: [
                _BoutonRond(
                  icone: Icons.remove_rounded,
                  onTap: () => _changerNbLots(l, -1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChampTexte(
                    controller: l.nbLots,
                    label: 'Nombre de paquets',
                    clavier: TextInputType.number,
                    formatteurs: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                _BoutonRond(
                  icone: Icons.add_rounded,
                  plein: true,
                  onTap: () => _changerNbLots(l, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ---- Étape 3 : articles par paquet
          _Etape(
            numero: 3,
            icone: Icons.category_outlined,
            fait: l.unitesInt > 0,
            question: nom == null
                ? "Combien d'articles y a-t-il dans 1 paquet ?"
                : 'Combien de « $nom » y a-t-il dans 1 paquet ?',
            aide: 'Comptez les articles que vous vendrez à vos clients.',
            child: ChampTexte(
              controller: l.unites,
              label: 'Articles dans 1 paquet',
              suffixe: 'article(s)',
              clavier: TextInputType.number,
              formatteurs: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(height: 14),

          // ---- Étape 4 : prix
          _Etape(
            numero: 4,
            icone: Icons.payments_outlined,
            fait: l.prixInt > 0,
            question: 'Combien avez-vous payé pour 1 paquet ?',
            aide: "Le prix d'UN seul paquet, pas le total de l'achat.",
            child: ChampTexte(
              controller: l.prix,
              label: 'Prix payé pour 1 paquet',
              icone: Icons.sell_outlined,
              suffixe: 'FCFA',
              clavier: TextInputType.number,
              formatteurs: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),

          // ---- Résumé
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: pret
                ? Padding(
              padding: const EdgeInsets.only(top: 18),
              child: _Resume(
                articles: l.totalUnites,
                coutArticle: l.coutUnitaire.round(),
                depense: l.depense,
              ),
            )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- composants

/// Titre de bloc : petite icône + texte.
class _TitreBloc extends StatelessWidget {
  final IconData icone;
  final String texte;
  const _TitreBloc({required this.icone, required this.texte});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Row(
      children: [
        Icon(icone, size: 20, color: Couleurs.bleu),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texte,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Couleurs.texte,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Carte d'accueil : une phrase simple + un exemple repliable.
class _CarteAccueil extends StatefulWidget {
  const _CarteAccueil();

  @override
  State<_CarteAccueil> createState() => _CarteAccueilState();
}

class _CarteAccueilState extends State<_CarteAccueil> {
  bool _ouvert = false;

  @override
  Widget build(BuildContext context) {
    return CarteNeo(
      rayon: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3ECFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.local_shipping_outlined,
                    color: Couleurs.bleu, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    'Vous avez acheté de la marchandise ? Suivez les 4 étapes : '
                        'vos articles sont ajoutés au stock et votre prix de revient '
                        'est calculé tout seul.',
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.45,
                      color: Couleurs.texte,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _ouvert = !_ouvert),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      size: 20, color: Color(0xFFF5B301)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Comment ça marche ?',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Couleurs.bleu,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _ouvert ? .5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Couleurs.bleu),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _ouvert
                ? Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Exemple : vous achetez 2 cartons de sucre. Chaque carton '
                    'contient 50 sachets et coûte 7 000 FCFA.\n\n'
                    'Vous écrivez : 2 paquets, 50 articles par paquet, '
                    '7 000 FCFA par paquet.\n\n'
                    'Résultat : 100 sachets sont ajoutés à votre stock.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: Couleurs.texte,
                ),
              ),
            )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// Une étape : bloc teinté avec pastille, question, aide et champ.
/// La pastille devient verte avec un ✓ quand l'étape est remplie.
class _Etape extends StatelessWidget {
  final int numero;
  final IconData icone;
  final bool fait;
  final String question;
  final String? aide;
  final Widget child;
  const _Etape({
    required this.numero,
    required this.icone,
    required this.fait,
    required this.question,
    required this.child,
    this.aide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _fondEtape,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fait ? _vert.withOpacity(.35) : _bordureEtape),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: fait ? _vert : Couleurs.bleu,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: fait
                      ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                      : Text(
                    '$numero',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Couleurs.texte,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icone, size: 22, color: Couleurs.texteDoux),
            ],
          ),
          if (aide != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(aide!, style: Typo.petit),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Bouton rond − / + pour le nombre de paquets.
class _BoutonRond extends StatelessWidget {
  final IconData icone;
  final VoidCallback onTap;
  final bool plein;
  const _BoutonRond({required this.icone, required this.onTap, this.plein = false});

  @override
  Widget build(BuildContext context) => Material(
    color: plein ? Couleurs.bleu : const Color(0xFFE3ECFF),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Icon(icone, size: 24, color: plein ? Colors.white : Couleurs.bleu),
      ),
    ),
  );
}

/// Résumé : carte bleue avec 3 phrases claires.
class _Resume extends StatelessWidget {
  final int articles;
  final int coutArticle;
  final int depense;
  const _Resume({
    required this.articles,
    required this.coutArticle,
    required this.depense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F5BE0), Color(0xFF0B2E8A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fact_check_outlined, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Ce qui sera enregistré',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _LigneResume(
            icone: Icons.inventory_2_outlined,
            texte: '$articles article${articles > 1 ? 's' : ''} '
                'ajouté${articles > 1 ? 's' : ''} à votre stock',
          ),
          const SizedBox(height: 12),
          _LigneResume(
            icone: Icons.sell_outlined,
            texte: 'Chaque article vous revient à ${formatFcfa(coutArticle)}',
          ),
          const SizedBox(height: 12),
          _LigneResume(
            icone: Icons.payments_outlined,
            texte: 'Vous dépensez ${formatFcfa(depense)} au total',
          ),
        ],
      ),
    );
  }
}

class _LigneResume extends StatelessWidget {
  final IconData icone;
  final String texte;
  const _LigneResume({required this.icone, required this.texte});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.16),
          shape: BoxShape.circle,
        ),
        child: Icon(icone, size: 18, color: Colors.white),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          texte,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.3,
          ),
        ),
      ),
    ],
  );
}

/// Message d'erreur dans un bloc rouge clair.
class _BoiteErreur extends StatelessWidget {
  final String message;
  const _BoiteErreur({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Couleurs.erreur.withOpacity(.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Couleurs.erreur.withOpacity(.3)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error_outline_rounded, size: 22, color: Couleurs.erreur),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: Couleurs.erreur,
            ),
          ),
        ),
      ],
    ),
  );
}