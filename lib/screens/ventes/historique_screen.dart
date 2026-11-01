import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../models/vente.dart';
import '../../providers/vente_provider.dart';
import '../../widgets/aide_info.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/courbe_ventes.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../../widgets/onglets_pilule.dart';
import 'detail_vente_screen.dart';

/// Onglet « Mes ventes » : période, courbe, détail par moyen de paiement, dernières ventes.
class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  static const _periodes = ['7j', '30j', '3m'];
  static const _libelles = ['7 jours', '30 jours', '3 mois'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<VenteProvider>().charger();
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = context.watch<VenteProvider>();
    final r = v.resume;
    final index = _periodes.indexOf(v.periode).clamp(0, 2).toInt();

    Widget contenu;
    if (v.erreur != null && r == null) {
      contenu = MessageErreur(
          message: v.erreur!,
          onReessayer: () => context.read<VenteProvider>().charger());
    } else if (r == null) {
      contenu = const SizedBox(height: 260, child: Chargement());
    } else {
      final dates = r.serie.where((p) => p.date != null).toList();
      contenu = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarteNeo(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(formatFcfa(r.totalFcfa),
                          style: Typo.titreEcran.copyWith(fontSize: 26)),
                    ),
                    if (r.variationPct != null)
                      PastilleStatut(
                        libelle:
                            '${r.variationPct! >= 0 ? '↑ +' : '↓ '}${r.variationPct!.toStringAsFixed(0)}%',
                        couleur: r.variationPct! >= 0
                            ? Couleurs.succes
                            : Couleurs.erreur,
                        fond: r.variationPct! >= 0
                            ? Couleurs.succesClair
                            : Couleurs.erreurClair,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                CourbeVentes(
                  points: r.serie,
                  couleur: Couleurs.bleu,
                  hauteur: 130,
                  afficherPoints: true,
                ),
                if (dates.length >= 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatJourCourt(dates.first.date!), style: Typo.petit),
                        Text(formatJourCourt(dates.last.date!), style: Typo.petit),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const TitreSection('Détail des ventes'),
          if (r.parMethode.isEmpty)
            const Text('Aucune vente sur cette période.', style: Typo.doux)
          else
            CarteNeo(
              child: Column(
                children: [
                  for (var i = 0; i < r.parMethode.length; i++) ...[
                    if (i > 0) const Divider(height: 22),
                    _LigneMethode(total: r.parMethode[i]),
                  ],
                ],
              ),
            ),
          const TitreSection('Dernières ventes'),
          if (r.ventes.isEmpty)
            const Text("Vos ventes apparaîtront ici.", style: Typo.doux)
          else
            for (final vente in r.ventes.take(20))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TuileVente(vente: vente),
              ),
        ],
      );
    }

    return CorpsNeo(
      titre: 'Mes ventes',
      defiler: true,
      onRefresh: () => context.read<VenteProvider>().charger(),
      child: Column(
        children: [
          OngletsPilule(
            libelles: _libelles,
            index: index,
            onChanged: (i) =>
                context.read<VenteProvider>().charger(periode: _periodes[i]),
          ),
          const SizedBox(height: 18),
          contenu,
        ],
      ),
    );
  }
}

class _LigneMethode extends StatelessWidget {
  final TotalMethode total;
  const _LigneMethode({required this.total});

  @override
  Widget build(BuildContext context) {
    final bitcoin = total.methode == 'lightning';
    return Row(
      children: [
        IconeRonde(
          icone: iconeMethode(total.methode),
          couleur: couleurMethode(total.methode),
          fond: fondMethode(total.methode),
          taille: 40,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Text(nomMethode(total.methode),
                  style: Typo.corps.copyWith(fontWeight: FontWeight.w600)),
              if (bitcoin)
                const AideInfo(
                  titre: 'Valeur des paiements Bitcoin',
                  texte: TextesAide.historiqueBitcoinInfo,
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatFcfa(total.totalFcfa), style: Typo.corps),
            if (bitcoin && total.totalSats != null)
              Text('(≈ ${formatBtc(total.totalSats!)})', style: Typo.petit),
          ],
        ),
      ],
    );
  }
}

class _TuileVente extends StatelessWidget {
  final Vente vente;
  const _TuileVente({required this.vente});

  @override
  Widget build(BuildContext context) {
    final m = vente.methode;
    return CarteNeo(
      padding: const EdgeInsets.all(14),
      rayon: 20,
      onTap: () => aller(context, DetailVenteScreen(venteId: vente.id)),
      child: Row(
        children: [
          IconeRonde(
            icone: m.isEmpty ? Icons.receipt_long_outlined : iconeMethode(m),
            couleur: m.isEmpty ? Couleurs.texteDoux : couleurMethode(m),
            fond: m.isEmpty ? Couleurs.champ : fondMethode(m),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vente.titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Typo.corps.copyWith(fontWeight: FontWeight.w700)),
                if (vente.creeLe != null)
                  Text(formatDateHeure(vente.creeLe!), style: Typo.petit),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatFcfa(vente.totalFcfa),
                  style: Typo.corps.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              PastilleStatut.vente(vente.statut),
            ],
          ),
        ],
      ),
    );
  }
}
