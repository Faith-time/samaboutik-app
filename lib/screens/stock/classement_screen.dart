import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/stock_outils.dart';
import '../../core/theme.dart';
import '../../models/stock.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../../widgets/onglets_pilule.dart';
import '../../widgets/stock_widgets.dart';
import '../produits/formulaire_produit_screen.dart';
import 'reapprovisionner_screen.dart';

/// Classement de TOUS les produits : du plus vendu au moins vendu.
class ClassementScreen extends StatefulWidget {
  const ClassementScreen({super.key});

  @override
  State<ClassementScreen> createState() => _ClassementScreenState();
}

class _ClassementScreenState extends State<ClassementScreen> {
  static const _periodes = ['jour', 'semaine', 'mois', 'annee'];
  static const _libellesPeriodes = ['Jour', 'Semaine', 'Mois', 'Année'];
  static const _tris = ['quantite', 'ca', 'benefice'];
  static const _libellesTris = ['Quantité', 'Ventes', 'Bénéfice'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StockProvider>().chargerClassement();
    });
  }

  String _explication(String periode) {
    switch (periode) {
      case 'jour':
        return "Aujourd'hui";
      case 'semaine':
        return 'Les 7 derniers jours';
      case 'mois':
        return 'Les 30 derniers jours';
      default:
        return 'Les 365 derniers jours';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<StockProvider>();
    final c = s.classement;
    final iP = _periodes.indexOf(s.periode).clamp(0, 3).toInt();
    final iT = _tris.indexOf(s.tri).clamp(0, 2).toInt();

    Widget contenu;
    if (s.erreurClassement != null && c == null) {
      contenu = MessageErreur(
          message: s.erreurClassement!,
          onReessayer: () => context.read<StockProvider>().chargerClassement());
    } else if (c == null) {
      contenu = const SizedBox(height: 260, child: Chargement());
    } else if (c.lignes.isEmpty) {
      contenu = EtatVide(
        icone: Icons.leaderboard_outlined,
        titre: 'Aucun produit',
        texte: 'Ajoutez vos produits pour voir leur classement.',
        libelleAction: 'Ajouter un produit',
        onAction: () => aller(context, const FormulaireProduitScreen()),
      );
    } else {
      contenu = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarteNeo(
            child: Row(
              children: [
                _Total(titre: 'Ventes', valeur: formatFcfa(c.totalCaFcfa)),
                _Total(titre: 'Bénéfice', valeur: formatFcfa(c.totalBeneficeFcfa)),
                _Total(titre: 'Vendus', valeur: '${c.totalQuantite}'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(_explication(c.periode), style: Typo.petit),
          ),
          const SizedBox(height: 10),
          for (final l in c.lignes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LigneRang(ligne: l),
            ),
        ],
      );
    }

    return EcranNeo(
      titre: 'Classement des produits',
      retour: true,
      defiler: true,
      onRefresh: () => context.read<StockProvider>().chargerClassement(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OngletsPilule(
            libelles: _libellesPeriodes,
            index: iP,
            onChanged: (i) =>
                context.read<StockProvider>().chargerClassement(periode: _periodes[i]),
          ),
          const SizedBox(height: 12),
          OngletsPilule(
            libelles: _libellesTris,
            index: iT,
            onChanged: (i) =>
                context.read<StockProvider>().chargerClassement(tri: _tris[i]),
          ),
          const SizedBox(height: 16),
          contenu,
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  final String titre;
  final String valeur;
  const _Total({required this.titre, required this.valeur});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(valeur,
                textAlign: TextAlign.center,
                style: Typo.corps.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(titre, style: Typo.petit),
          ],
        ),
      );
}

class _Rang extends StatelessWidget {
  final int rang;
  const _Rang(this.rang);

  @override
  Widget build(BuildContext context) {
    final Color? medaille = rang == 1
        ? const Color(0xFFF5B301)
        : rang == 2
            ? const Color(0xFF9AA5B8)
            : rang == 3
                ? const Color(0xFFCD7F32)
                : null;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: medaille ?? Couleurs.champ,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: medaille != null
            ? Text('$rang',
                style: const TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))
            : Text('$rang',
                style: const TextStyle(
                    color: Couleurs.texteDoux,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _LigneRang extends StatelessWidget {
  final LigneClassement ligne;
  const _LigneRang({required this.ligne});

  @override
  Widget build(BuildContext context) {
    final l = ligne;
    final vendu = l.quantite > 0;
    final couleur = couleurStatutStock(l.statutStock);

    return CarteNeo(
      rayon: 20,
      padding: const EdgeInsets.all(14),
      onTap: () => aller(context, ReapprovisionnerScreen(produitId: l.produitId)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Rang(l.rang),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l.nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Typo.corps.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Text(formatFcfa(l.caFcfa),
                        style: Typo.corps.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  vendu
                      ? '${l.quantite} vendu${l.quantite > 1 ? 's' : ''}'
                          '${l.beneficeFcfa != null ? ' · bénéfice ${formatFcfa(l.beneficeFcfa!)}' : ''}'
                          ' · ${l.partPct.toStringAsFixed(0)} % des ventes'
                      : 'Aucune vente sur la période',
                  style: Typo.petit,
                ),
                const SizedBox(height: 8),
                if (l.suivreStock && l.niveauStock != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: l.niveauStock!.clamp(0.0, 1.0),
                      minHeight: 6,
                      color: couleur,
                      backgroundColor: Couleurs.champ,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Stock : ${texteUnites(l.stockActuel)}'
                          '${l.lotsRestants != null ? ' (${texteLots(l.lotsRestants!)})' : ''}',
                          style: Typo.petit,
                        ),
                      ),
                      PastilleStock(l.statutStock),
                    ],
                  ),
                ] else
                  const Text('Stock non suivi', style: Typo.petit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
