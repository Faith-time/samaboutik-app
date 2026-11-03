import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../../widgets/stock_widgets.dart';
import 'classement_screen.dart';
import 'historique_achats_screen.dart';
import 'reapprovisionner_screen.dart';

/// Mon stock : valeur, alertes, et état de chaque produit.
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
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
    final d = s.donnees;

    Widget contenu;
    if (s.erreur != null && d == null) {
      contenu = MessageErreur(
          message: s.erreur!,
          onReessayer: () => context.read<StockProvider>().charger());
    } else if (d == null) {
      contenu = const SizedBox(height: 260, child: Chargement());
    } else {
      final alertes = s.alertes;
      contenu = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CarteStat(
                  icone: Icons.inventory_2_outlined,
                  titre: 'Valeur du stock',
                  valeur: formatFcfa(d.resume.valeurStockFcfa),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CarteStat(
                  icone: Icons.shopping_basket_outlined,
                  titre: 'Achats (30 jours)',
                  valeur: formatFcfa(d.resume.depenses30jFcfa),
                ),
              ),
            ],
          ),
          if (alertes.isNotEmpty) ...[
            const TitreSection('À réapprovisionner'),
            for (final p in alertes)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TuileStock(produit: p),
              ),
          ],
          const TitreSection('Tous les produits'),
          if (d.produits.isEmpty)
            const Text("Ajoutez d'abord vos produits.", style: Typo.doux)
          else
            for (final p in d.produits)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TuileStock(produit: p),
              ),
          if (d.produits.any((p) => !p.suivreStock))
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Pour suivre le stock d\'un produit « non suivi », ouvrez sa fiche dans Mes produits et activez le suivi du stock.',
                style: Typo.petit,
              ),
            ),
        ],
      );
    }

    return EcranNeo(
      titre: 'Mon stock',
      retour: true,
      defiler: true,
      onRefresh: () => context.read<StockProvider>().charger(),
      bas: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BoutonPrincipal(
            texte: 'Réapprovisionner',
            icone: Icons.add_shopping_cart_rounded,
            onPressed: () => aller(context, const ReapprovisionnerScreen()),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: BoutonPrincipal(
                  texte: 'Achats',
                  secondaire: true,
                  onPressed: () => aller(context, const HistoriqueAchatsScreen()),
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
      ),
      child: contenu,
    );
  }
}
