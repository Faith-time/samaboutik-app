import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../providers/rapport_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../dashboard/tableau_de_bord_screen.dart';

/// Onglet « Analyse IA » : résumé et conseils personnalisés.
class ConseilsScreen extends StatefulWidget {
  const ConseilsScreen({super.key});

  @override
  State<ConseilsScreen> createState() => _ConseilsScreenState();
}

class _ConseilsScreenState extends State<ConseilsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RapportProvider>().charger();
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.watch<RapportProvider>();
    final rapport = r.rapport;

    Widget contenu;
    if (r.erreur != null && rapport == null) {
      contenu = MessageErreur(
          message: r.erreur!,
          onReessayer: () => context.read<RapportProvider>().charger());
    } else if (rapport == null) {
      contenu = const SizedBox(height: 260, child: Chargement());
    } else {
      contenu = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rapport.resume.isNotEmpty)
            CarteNeo(
              couleur: Couleurs.bleuClair,
              ombres: const [],
              child: Row(
                children: [
                  const IconeRonde(
                    icone: Icons.lightbulb_outline_rounded,
                    couleur: Couleurs.bitcoin,
                    fond: Colors.white,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Text(rapport.resume,
                          style: Typo.corps.copyWith(fontWeight: FontWeight.w600))),
                  const SizedBox(width: 10),
                  const Icon(Icons.bar_chart_rounded,
                      color: Couleurs.bleu, size: 38),
                ],
              ),
            ),
          const TitreSection('Conseils pour vous'),
          if (rapport.conseils.isEmpty)
            const Text(
                "Enregistrez quelques ventes pour recevoir vos premiers conseils.",
                style: Typo.doux)
          else
            for (final c in rapport.conseils)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CarteNeo(
                  rayon: 20,
                  child: Row(
                    children: [
                      const IconeRonde(icone: Icons.tips_and_updates_outlined),
                      const SizedBox(width: 14),
                      Expanded(child: Text(c, style: Typo.corps)),
                    ],
                  ),
                ),
              ),
        ],
      );
    }

    return CorpsNeo(
      titre: 'Analyse IA',
      defiler: true,
      onRefresh: () => context.read<RapportProvider>().charger(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: Couleurs.texteDoux),
              SizedBox(width: 8),
              Expanded(child: Text(TextesAide.conseilsIa, style: Typo.petit)),
            ],
          ),
          const SizedBox(height: 16),
          contenu,
          const SizedBox(height: 20),
          BoutonPrincipal(
            texte: "Voir plus d'analyses",
            secondaire: true,
            icone: Icons.bar_chart_rounded,
            onPressed: () => aller(context, const TableauDeBordScreen()),
          ),
        ],
      ),
    );
  }
}
