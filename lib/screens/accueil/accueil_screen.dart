import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tableau_bord_provider.dart';
import '../../widgets/barre_navigation.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/courbe_ventes.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../bitcoin/comprendre_bitcoin_screen.dart';
import '../conseils/conseils_screen.dart';
import '../produits/liste_produits_screen.dart';
import '../profil/profil_screen.dart';
import '../ventes/historique_screen.dart';
import '../ventes/nouvelle_vente_screen.dart';
import '../stock/classement_screen.dart';
import '../stock/stock_screen.dart';
import '../../widgets/stock_widgets.dart';

/// Écran principal : 4 onglets (Accueil, Ventes, Analyse, Profil).
class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  int _index = 0;
  // Un onglet n'est construit (et ses données chargées) qu'à sa première visite.
  final Set<int> _visites = {0};

  void _aller(int i) => setState(() {
        _index = i;
        _visites.add(i);
      });

  @override
  Widget build(BuildContext context) {
    final onglets = <Widget>[
      _AccueilOnglet(
        onVentes: () => _aller(1),
        onAnalyse: () => _aller(2),
        onProfil: () => _aller(3),
      ),
      _visites.contains(1) ? const HistoriqueScreen() : const SizedBox.shrink(),
      _visites.contains(2) ? const ConseilsScreen() : const SizedBox.shrink(),
      _visites.contains(3) ? const ProfilScreen() : const SizedBox.shrink(),
    ];
    return Scaffold(
      backgroundColor: Couleurs.fondHaut,
      body: FondNeo(child: IndexedStack(index: _index, children: onglets)),
      bottomNavigationBar: BarreNavigation(index: _index, onChanged: _aller),
    );
  }
}

class _AccueilOnglet extends StatefulWidget {
  final VoidCallback onVentes;
  final VoidCallback onAnalyse;
  final VoidCallback onProfil;
  const _AccueilOnglet({
    required this.onVentes,
    required this.onAnalyse,
    required this.onProfil,
  });

  @override
  State<_AccueilOnglet> createState() => _AccueilOngletState();
}

class _AccueilOngletState extends State<_AccueilOnglet> {
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
    final nom = context.watch<AuthProvider>().utilisateur?.nom ?? '';
    final prenom = nom.trim().isEmpty ? '' : nom.trim().split(' ').first;
    final d = tb.donnees;

    return CorpsNeo(
      defiler: true,
      onRefresh: () => context.read<TableauBordProvider>().charger(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.menu_rounded,
                    size: 28, color: Couleurs.texte),
                onPressed: widget.onProfil,
              ),
              const CloucheStock(),
            ],
          ),
          const SizedBox(height: 6),
          Text('Bonjour, $prenom 👋', style: Typo.titreEcran),
          const SizedBox(height: 2),
          const Text("Voici un aperçu de votre activité", style: Typo.doux),
          const SizedBox(height: 20),
          if (tb.erreur != null && d == null)
            MessageErreur(
                message: tb.erreur!,
                onReessayer: () => context.read<TableauBordProvider>().charger())
          else if (d == null)
            const SizedBox(height: 220, child: Chargement())
          else ...[
            CarteHero(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bar_chart_rounded,
                                color: Colors.white70, size: 18),
                            SizedBox(width: 6),
                            Text('Ventes du jour',
                                style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(formatFcfa(d.ventesJourFcfa),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800)),
                        if (d.variationPct != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                d.variationPct! >= 0
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 16,
                                color: d.variationPct! >= 0
                                    ? const Color(0xFF7CE6A6)
                                    : const Color(0xFFFFA3A3),
                              ),
                              Text(
                                '${d.variationPct! >= 0 ? '+' : ''}${d.variationPct!.toStringAsFixed(0)}%',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: d.variationPct! >= 0
                                        ? const Color(0xFF7CE6A6)
                                        : const Color(0xFFFFA3A3)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: CourbeVentes(points: d.serie, hauteur: 70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CarteStat(
                    icone: Icons.shopping_cart_outlined,
                    titre: 'Total ventes (30 jours)',
                    valeur: formatFcfa(d.total30jFcfa),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: CarteStat(
                    icone: Icons.currency_bitcoin_rounded,
                    couleurIcone: Couleurs.bitcoin,
                    fondIcone: Couleurs.bitcoinClair,
                    titre: 'Ventes Bitcoin (30 jours)',
                    valeur: d.bitcoin30jSats != null
                        ? formatBtc(d.bitcoin30jSats!)
                        : formatFcfa(d.bitcoin30jFcfa),
                    sousTitre: '≈ ${formatFcfa(d.bitcoin30jFcfa)}',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const CarteAlertesStock(),
          const SizedBox(height: 22),
          Center(
            child: SizedBox(
              width: 240,
              child: BoutonPrincipal(
                texte: 'Nouvelle vente',
                icone: Icons.add_rounded,
                onPressed: () => aller(context, const NouvelleVenteScreen()),
              ),
            ),
          ),
          const TitreSection('Actions rapides'),
          Row(
            children: [
              Expanded(
                child: _Action(
                  icone: Icons.inventory_2_outlined,
                  libelle: 'Mes produits',
                  onTap: () => aller(context, const ListeProduitsScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Action(
                  icone: Icons.receipt_long_outlined,
                  libelle: 'Mes ventes',
                  onTap: widget.onVentes,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Action(
                  icone: Icons.auto_awesome_rounded,
                  libelle: 'Analyse IA',
                  onTap: widget.onAnalyse,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Action(
                  icone: Icons.inventory_rounded,
                  libelle: 'Mon stock',
                  onTap: () => aller(context, const StockScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Action(
                  icone: Icons.leaderboard_rounded,
                  libelle: 'Classement',
                  onTap: () => aller(context, const ClassementScreen()),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final VoidCallback onTap;
  const _Action(
      {required this.icone, required this.libelle, required this.onTap});

  @override
  Widget build(BuildContext context) => CarteNeo(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        rayon: 20,
        onTap: onTap,
        child: Column(
          children: [
            IconeRonde(icone: icone, taille: 42),
            const SizedBox(height: 10),
            Text(libelle,
                textAlign: TextAlign.center,
                style: Typo.petit
                    .copyWith(color: Couleurs.texte, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
