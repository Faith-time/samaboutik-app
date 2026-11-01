import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../models/tableau_bord.dart';
import '../../providers/tableau_bord_provider.dart';
import '../../widgets/aide_info.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/courbe_ventes.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../../models/vente.dart';

/// Statistiques détaillées : recettes, panier moyen, répartition par moyen de paiement.
class TableauDeBordScreen extends StatefulWidget {
  const TableauDeBordScreen({super.key});

  @override
  State<TableauDeBordScreen> createState() => _TableauDeBordScreenState();
}

class _TableauDeBordScreenState extends State<TableauDeBordScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TableauBordProvider>().charger();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tb = context.watch<TableauBordProvider>();
    final d = tb.donnees;

    Widget contenu;
    if (tb.erreur != null && d == null) {
      contenu = MessageErreur(
          message: tb.erreur!,
          onReessayer: () => context.read<TableauBordProvider>().charger());
    } else if (d == null) {
      contenu = const SizedBox(height: 300, child: Chargement());
    } else {
      contenu = _Contenu(d: d);
    }

    return EcranNeo(
      titre: 'Statistiques',
      retour: true,
      defiler: true,
      onRefresh: () => context.read<TableauBordProvider>().charger(),
      child: contenu,
    );
  }
}

class _Contenu extends StatelessWidget {
  final TableauBord d;
  const _Contenu({required this.d});

  @override
  Widget build(BuildContext context) {
    final totalMethodes =
        d.parMethode.fold<int>(0, (s, m) => s + m.totalFcfa);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarteHero(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recettes de la semaine',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text(formatFcfa(d.ventesSemaineFcfa),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              CourbeVentes(points: d.serie, hauteur: 80),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CarteStat(
                icone: Icons.today_outlined,
                titre: "Aujourd'hui",
                valeur: formatFcfa(d.ventesJourFcfa),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CarteStat(
                icone: Icons.receipt_long_outlined,
                titre: 'Ventes du jour',
                valeur: '${d.nbVentesJour}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CarteStat(
          icone: Icons.shopping_basket_outlined,
          titre: 'Panier moyen',
          valeur: formatFcfa(d.panierMoyenFcfa),
        ),
        const TitreSection('Répartition par moyen de paiement'),
        if (d.parMethode.isEmpty)
          const Text('Aucune vente pour le moment.', style: Typo.doux)
        else
          CarteNeo(
            child: Column(
              children: [
                for (var i = 0; i < d.parMethode.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _BarreMethode(
                    total: d.parMethode[i],
                    part: totalMethodes == 0
                        ? 0
                        : d.parMethode[i].totalFcfa / totalMethodes,
                  ),
                ],
              ],
            ),
          ),
        if (d.beneficeEstimeFcfa != null) ...[
          const TitreSection('Bénéfice estimé'),
          CarteNeo(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatFcfa(d.beneficeEstimeFcfa!), style: Typo.montant),
                const SizedBox(height: 6),
                const Text(
                  "Attention : le total des ventes n'est pas le bénéfice. "
                  "Cette estimation utilise les prix d'achat que vous avez renseignés.",
                  style: Typo.petit,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BarreMethode extends StatelessWidget {
  final TotalMethode total;
  final double part;
  const _BarreMethode({required this.total, required this.part});

  @override
  Widget build(BuildContext context) {
    final bitcoin = total.methode == 'lightning';
    final couleur = couleurMethode(total.methode);
    return Column(
      children: [
        Row(
          children: [
            IconeRonde(
              icone: iconeMethode(total.methode),
              couleur: couleur,
              fond: fondMethode(total.methode),
              taille: 34,
            ),
            const SizedBox(width: 10),
            Text(nomMethode(total.methode),
                style: Typo.corps.copyWith(fontWeight: FontWeight.w600)),
            if (bitcoin)
              const AideInfo(
                titre: 'Paiements Bitcoin',
                texte: TextesAide.tableauBordBitcoinInfo,
              ),
            const Spacer(),
            Text(formatFcfa(total.totalFcfa), style: Typo.corps),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: part.clamp(0.0, 1.0),
            minHeight: 8,
            color: couleur,
            backgroundColor: Couleurs.champ,
          ),
        ),
      ],
    );
  }
}
