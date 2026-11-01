import 'package:flutter/material.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';

/// Page d'aide : questions fréquentes sur le Bitcoin, Lightning, les codes QR et les sats.
class ComprendreBitcoinScreen extends StatelessWidget {
  const ComprendreBitcoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EcranNeo(
      titre: 'Comprendre le Bitcoin',
      retour: true,
      defiler: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarteNeo(
            child: Row(
              children: [
                const IconeRonde(
                  icone: Icons.currency_bitcoin_rounded,
                  couleur: Colors.white,
                  fond: Couleurs.bitcoin,
                  taille: 56,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Tout ce qu\'il faut savoir pour recevoir un paiement en Bitcoin, simplement.',
                    style: Typo.corps,
                  ),
                ),
              ],
            ),
          ),
          const TitreSection('Questions fréquentes'),
          CarteNeo(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Column(
                children: [
                  for (var i = 0; i < TextesAide.faq.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 14),
                      expandedAlignment: Alignment.centerLeft,
                      title: Text(TextesAide.faq[i][0],
                          style: Typo.corps.copyWith(fontWeight: FontWeight.w700)),
                      children: [
                        Text(TextesAide.faq[i][1], style: Typo.doux),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
