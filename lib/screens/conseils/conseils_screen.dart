import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/stock_outils.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../models/stock.dart';
import '../../models/vente.dart';
import '../../providers/rapport_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/tableau_bord_provider.dart';
import '../../services/stock_service.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/courbe_ventes.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../dashboard/tableau_de_bord_screen.dart';
import '../stock/classement_screen.dart';
import '../stock/reapprovisionner_screen.dart';

/// Onglet « Analyse IA » : chiffres, courbes, produits stars, alertes et conseils.
class ConseilsScreen extends StatefulWidget {
  const ConseilsScreen({super.key});

  @override
  State<ConseilsScreen> createState() => _ConseilsScreenState();
}

class _ConseilsScreenState extends State<ConseilsScreen> {
  Classement? _top; // classement des 30 derniers jours

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _charger();
    });
  }

  Future<void> _chargerTop() async {
    try {
      final c = await StockService().classement('mois', 'quantite');
      if (mounted) setState(() => _top = c);
    } catch (_) {
      // Les produits stars sont facultatifs : on n'affiche rien si ça échoue
    }
  }

  Future<void> _charger() async {
    await Future.wait([
      context.read<RapportProvider>().charger(),
      context.read<TableauBordProvider>().charger(),
      context.read<StockProvider>().charger(),
      _chargerTop(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final r = context.watch<RapportProvider>();
    final tb = context.watch<TableauBordProvider>();
    final stock = context.watch<StockProvider>();
    final rapport = r.rapport;
    final d = tb.donnees;
    final alertes = stock.alertes.take(3).toList();
    final stars = (_top?.lignes ?? const <LigneClassement>[])
        .where((l) => l.quantite > 0)
        .take(3)
        .toList();
    final maxQte = stars.isEmpty ? 1 : stars.first.quantite;
    final conseils = rapport?.conseils ?? const <String>[];

    Widget contenu;
    if (tb.erreur != null && d == null && rapport == null) {
      contenu = MessageErreur(message: tb.erreur!, onReessayer: _charger);
    } else if (d == null && rapport == null) {
      contenu = const SizedBox(height: 300, child: Chargement());
    } else {
      contenu = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------ Cette semaine
          if (d != null) ...[
            CarteHero(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.show_chart_rounded, color: Colors.white70, size: 22),
                      SizedBox(width: 8),
                      Text('Vos ventes cette semaine',
                          style: TextStyle(color: Colors.white70, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(formatFcfa(d.ventesSemaineFcfa),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800)),
                  ),
                  if (d.variationPct != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          d.variationPct! >= 0
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 20,
                          color: d.variationPct! >= 0
                              ? const Color(0xFF7CE6A6)
                              : const Color(0xFFFFA3A3),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${d.variationPct! >= 0 ? '+' : ''}${d.variationPct!.toStringAsFixed(0)} % par rapport à la semaine dernière',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: d.variationPct! >= 0
                                  ? const Color(0xFF7CE6A6)
                                  : const Color(0xFFFFA3A3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  CourbeVentes(points: d.serie, hauteur: 120),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CarteStat(
                    icone: Icons.shopping_basket_outlined,
                    titre: 'Panier moyen',
                    valeur: formatFcfa(d.panierMoyenFcfa),
                    sousTitre: 'par client',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: CarteStat(
                    icone: Icons.calendar_month_outlined,
                    titre: 'Ventes (30 jours)',
                    valeur: formatFcfa(d.total30jFcfa),
                  ),
                ),
              ],
            ),
            if (stock.donnees != null) ...[
              const SizedBox(height: 14),
              CarteStat(
                icone: Icons.trending_up_rounded,
                titre: 'Bénéfice (30 jours)',
                valeur: formatFcfa(stock.donnees!.resume.benefice30jFcfa),
                sousTitre: 'Ce qu\'il vous reste après avoir payé vos produits',
              ),
            ],
            const SizedBox(height: 22),
            CarteNeo(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jour par jour', style: Typo.sousTitre),
                  const SizedBox(height: 4),
                  const Text('Le jour en bleu foncé est votre meilleur jour.',
                      style: Typo.petit),
                  const SizedBox(height: 18),
                  _BarresSemaine(points: d.serie),
                ],
              ),
            ),
          ],

          // ------------------------------------------------ Produits stars
          if (stars.isNotEmpty) ...[
            const SizedBox(height: 8),
            const TitreSection('Vos produits stars (30 jours)'),
            for (var i = 0; i < stars.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CarteStar(rang: i + 1, ligne: stars[i], maxQte: maxQte),
              ),
          ],

          // ------------------------------------------------ À faire maintenant
          if (alertes.isNotEmpty) ...[
            const SizedBox(height: 8),
            const TitreSection('À faire maintenant'),
            for (final p in alertes)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CarteAlerte(produit: p),
              ),
          ],

          // ------------------------------------------------ Conseils
          const SizedBox(height: 8),
          const TitreSection('Conseils pour vous'),
          if (conseils.isEmpty)
            const Text(
              'Enregistrez quelques ventes pour recevoir vos premiers conseils.',
              style: TextStyle(fontSize: 15, height: 1.45, color: Couleurs.texteDoux),
            )
          else
            for (final c in conseils)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CarteConseil(texte: c),
              ),

          const SizedBox(height: 14),
          BoutonPrincipal(
            texte: 'Classement des produits',
            icone: Icons.leaderboard_rounded,
            onPressed: () => aller(context, const ClassementScreen()),
          ),
          const SizedBox(height: 12),
          BoutonPrincipal(
            texte: 'Toutes les statistiques',
            secondaire: true,
            icone: Icons.bar_chart_rounded,
            onPressed: () => aller(context, const TableauDeBordScreen()),
          ),
          const SizedBox(height: 22),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Couleurs.texteDoux),
              SizedBox(width: 8),
              Expanded(child: Text(TextesAide.conseilsIa, style: Typo.petit)),
            ],
          ),
        ],
      );
    }

    return CorpsNeo(
      titre: 'Analyse IA',
      defiler: true,
      onRefresh: _charger,
      child: contenu,
    );
  }
}

// ---------------------------------------------------------------- composants

/// Histogramme des 7 derniers jours (lettres : L M M J V S D).
class _BarresSemaine extends StatelessWidget {
  final List<PointSerie> points;
  const _BarresSemaine({required this.points});

  static const _jours = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  String _court(int n) {
    if (n < 1000) return '$n';
    final k = n / 1000;
    return '${k.toStringAsFixed(n >= 10000 ? 0 : 1).replaceAll('.', ',')}k';
  }

  @override
  Widget build(BuildContext context) {
    final maxV = points.fold<int>(0, (m, p) => p.totalFcfa > m ? p.totalFcfa : m);
    return SizedBox(
      height: 170,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final p in points)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (p.totalFcfa > 0)
                    Text(_court(p.totalFcfa),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Container(
                    height: maxV == 0 ? 6 : 6 + 100 * p.totalFcfa / maxV,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: (maxV > 0 && p.totalFcfa == maxV)
                          ? Couleurs.bleuFonce
                          : Couleurs.bleu.withValues(alpha: .3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.date == null ? '' : _jours[p.date!.weekday - 1],
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Couleurs.texteDoux),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CarteStar extends StatelessWidget {
  final int rang;
  final LigneClassement ligne;
  final int maxQte;
  const _CarteStar({required this.rang, required this.ligne, required this.maxQte});

  @override
  Widget build(BuildContext context) {
    final l = ligne;
    final m = rang == 1
        ? const Color(0xFFF5B301)
        : rang == 2
        ? const Color(0xFF9AA5B8)
        : const Color(0xFFCD7F32);
    return CarteNeo(
      rayon: 22,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: m, shape: BoxShape.circle),
            child: Center(
              child: Text('$rang',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${l.quantite} vendus',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: Couleurs.bleu)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: maxQte == 0 ? 0 : l.quantite / maxQte,
                    minHeight: 9,
                    color: m,
                    backgroundColor: Couleurs.champ,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatFcfa(l.caFcfa),
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
              const Text('de ventes', style: Typo.petit),
              if (l.beneficeFcfa != null) ...[
                const SizedBox(height: 6),
                Text(formatFcfa(l.beneficeFcfa!),
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Couleurs.succes)),
                const Text('de bénéfice', style: Typo.petit),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CarteAlerte extends StatelessWidget {
  final StockProduit produit;
  const _CarteAlerte({required this.produit});

  @override
  Widget build(BuildContext context) {
    final p = produit;
    final couleur = couleurStatutStock(p.statutStock);
    final message = p.epuise
        ? 'Épuisé : vous ne pouvez plus le vendre.'
        : 'Il ne reste que ${texteUnites(p.stockActuel)}'
        '${p.joursRestants != null ? ' (environ ${texteJours(p.joursRestants!)} de ventes)' : ''}.';
    return CarteNeo(
      rayon: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconeRonde(
                icone: Icons.warning_amber_rounded,
                couleur: couleur,
                fond: fondStatutStock(p.statutStock),
                taille: 48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nom,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(message,
                        style: const TextStyle(
                            fontSize: 14, height: 1.35, color: Couleurs.texteDoux)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BoutonPrincipal(
            texte: 'Racheter ${p.nom}',
            icone: Icons.add_shopping_cart_rounded,
            secondaire: !p.epuise,
            onPressed: () =>
                aller(context, ReapprovisionnerScreen(produitId: p.produitId)),
          ),
        ],
      ),
    );
  }
}

class _CarteConseil extends StatelessWidget {
  final String texte;
  const _CarteConseil({required this.texte});

  (IconData, Color) _style() {
    final t = texte.toLowerCase();
    if (t.contains('épuisé')) return (Icons.warning_amber_rounded, Couleurs.erreur);
    if (t.contains('racheter') || t.contains('reste')) {
      return (Icons.inventory_2_outlined, Couleurs.bitcoin);
    }
    if (t.contains('rentable')) return (Icons.trending_up_rounded, Couleurs.succes);
    if (t.contains('marge')) return (Icons.percent_rounded, Couleurs.bitcoin);
    if (t.contains('pas vendu')) return (Icons.hourglass_empty_rounded, Couleurs.texteDoux);
    if (t.contains('samedi') || t.contains('dimanche') || t.contains('lundi') ||
        t.contains('mardi') || t.contains('mercredi') || t.contains('jeudi') ||
        t.contains('vendredi')) {
      return (Icons.calendar_month_rounded, Couleurs.bleu);
    }
    return (Icons.lightbulb_outline_rounded, Couleurs.bleu);
  }

  @override
  Widget build(BuildContext context) {
    final (icone, couleur) = _style();
    return CarteNeo(
      rayon: 22,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconeRonde(
            icone: icone,
            couleur: couleur,
            fond: couleur.withValues(alpha: .12),
            taille: 48,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                texte,
                style: const TextStyle(
                    fontSize: 15.5, height: 1.45, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}