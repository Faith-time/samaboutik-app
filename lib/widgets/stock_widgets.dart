import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/formatters.dart';
import '../core/routes.dart';
import '../core/stock_outils.dart';
import '../core/theme.dart';
import '../models/stock.dart';
import '../providers/stock_provider.dart';
import '../screens/stock/classement_screen.dart';
import '../screens/stock/reapprovisionner_screen.dart';
import '../screens/stock/stock_screen.dart';
import 'bouton_principal.dart';
import 'carte_neo.dart';
import 'chargement.dart';
import 'composants_neo.dart';
import 'image_produit.dart';

/// Pastille « En stock / Stock bas / Épuisé » (rien si le stock n'est pas suivi).
class PastilleStock extends StatelessWidget {
  final String statut;
  const PastilleStock(this.statut, {super.key});

  @override
  Widget build(BuildContext context) {
    if (statut == 'non_suivi') return const SizedBox.shrink();
    return PastilleStatut(
      libelle: libelleStatutStock(statut),
      couleur: couleurStatutStock(statut),
      fond: fondStatutStock(statut),
    );
  }
}

/// Une ligne de la liste du stock. Toucher = réapprovisionner ce produit.
class TuileStock extends StatelessWidget {
  final StockProduit produit;
  final VoidCallback? onTap;
  const TuileStock({super.key, required this.produit, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = produit;
    final couleur = couleurStatutStock(p.statutStock);

    String detail;
    if (!p.suivreStock) {
      detail = 'Stock non suivi';
    } else {
      detail = texteUnites(p.stockActuel);
      if (p.unitesParLot > 1 && p.lotsRestants != null) {
        detail += ' · ${texteLots(p.lotsRestants!)}';
      }
    }
    final duree = (p.suivreStock && p.joursRestants != null && p.stockActuel > 0)
        ? 'Suffisant pour environ ${texteJours(p.joursRestants!)}'
        : null;

    return CarteNeo(
      rayon: 20,
      padding: const EdgeInsets.all(14),
      onTap: onTap ??
          () => aller(context, ReapprovisionnerScreen(produitId: p.produitId)),
      child: Row(
        children: [
          VignetteProduit(
            produitId: p.produitId,
            nom: p.nom,
            taille: 52,
            repli: IconeRonde(
              icone: Icons.inventory_2_outlined,
              couleur: couleur,
              fond: fondStatutStock(p.statutStock),
              taille: 52,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Typo.corps.copyWith(fontWeight: FontWeight.w700)),
                Text(detail, style: Typo.petit),
                if (duree != null) Text(duree, style: Typo.petit),
              ],
            ),
          ),
          PastilleStock(p.statutStock),
        ],
      ),
    );
  }
}

/// Clochette de l'accueil : pastille rouge = nombre de produits à racheter.
class CloucheStock extends StatelessWidget {
  const CloucheStock({super.key});

  void _ouvrir(BuildContext context, List<StockProduit> alertes) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alertes de stock', style: Typo.titre),
              const SizedBox(height: 14),
              if (alertes.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 18),
                  child: Text('Aucune alerte : votre stock est en ordre.',
                      style: Typo.doux),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: alertes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => TuileStock(
                      produit: alertes[i],
                      onTap: () {
                        Navigator.of(ctx).pop();
                        aller(context,
                            ReapprovisionnerScreen(produitId: alertes[i].produitId));
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              BoutonPrincipal(
                texte: 'Voir mon stock',
                secondaire: true,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  aller(context, const StockScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alertes = context.watch<StockProvider>().alertes;
    final n = alertes.length;
    return IconButton(
      padding: EdgeInsets.zero,
      alignment: Alignment.centerRight,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none_rounded,
              size: 28, color: Couleurs.texte),
          if (n > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Couleurs.erreur, shape: BoxShape.circle),
                child: Text('$n',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
      onPressed: () => _ouvrir(context, alertes),
    );
  }
}

/// Carte d'alerte de l'accueil (invisible quand tout va bien).
class CarteAlertesStock extends StatefulWidget {
  const CarteAlertesStock({super.key});

  @override
  State<CarteAlertesStock> createState() => _CarteAlertesStockState();
}

class _CarteAlertesStockState extends State<CarteAlertesStock> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StockProvider>().charger();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alertes = context.watch<StockProvider>().alertes;
    if (alertes.isEmpty) return const SizedBox.shrink();

    final epuises = alertes.where((p) => p.epuise).length;
    final couleur = epuises > 0 ? Couleurs.erreur : Couleurs.bitcoin;
    final noms = alertes.take(3).map((p) => p.nom).join(', ');
    final suite = alertes.length > 3 ? '…' : '';

    return CarteNeo(
      couleur: epuises > 0 ? Couleurs.erreurClair : Couleurs.bitcoinClair,
      ombres: const [],
      rayon: 20,
      onTap: () => aller(context, const StockScreen()),
      child: Row(
        children: [
          IconeRonde(
              icone: Icons.warning_amber_rounded, couleur: couleur, fond: Colors.white),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alertes.length == 1
                      ? '1 produit à racheter'
                      : '${alertes.length} produits à racheter',
                  style: Typo.corps.copyWith(fontWeight: FontWeight.w700),
                ),
                Text('$noms$suite', style: Typo.petit),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Couleurs.texteDoux),
        ],
      ),
    );
  }
}

/// Section « Stock et finances » de l'écran Statistiques.
class SectionStockFinances extends StatefulWidget {
  const SectionStockFinances({super.key});

  @override
  State<SectionStockFinances> createState() => _SectionStockFinancesState();
}

class _SectionStockFinancesState extends State<SectionStockFinances> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StockProvider>().charger();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<StockProvider>();
    final r = s.donnees?.resume;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitreSection('Stock et finances (30 jours)'),
        if (r == null)
          SizedBox(
            height: 90,
            child: s.chargement ? const Chargement() : const SizedBox.shrink(),
          )
        else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CarteStat(
                  icone: Icons.inventory_2_outlined,
                  titre: 'Valeur du stock',
                  valeur: formatFcfa(r.valeurStockFcfa),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CarteStat(
                  icone: Icons.shopping_basket_outlined,
                  titre: 'Achats (dépenses)',
                  valeur: formatFcfa(r.depenses30jFcfa),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CarteStat(
            icone: Icons.trending_up_rounded,
            titre: 'Bénéfice',
            valeur: formatFcfa(r.benefice30jFcfa),
            sousTitre: r.lignesSansCout > 0
                ? "Prix d'achat manquant sur certains produits"
                : 'Ventes moins le coût des produits vendus',
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: BoutonPrincipal(
                texte: 'Mon stock',
                secondaire: true,
                onPressed: () => aller(context, const StockScreen()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BoutonPrincipal(
                texte: 'Classement',
                secondaire: true,
                onPressed: () => aller(context, const ClassementScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
