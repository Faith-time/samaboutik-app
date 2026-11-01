import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'bouton_principal.dart';
import 'composants_neo.dart';

/// Affiche une explication courte dans une feuille en bas de l'écran.
Future<void> afficherAide(BuildContext context, String titre, String texte) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconeRonde(icone: Icons.info_outline_rounded, taille: 40),
                const SizedBox(width: 12),
                Expanded(child: Text(titre, style: Typo.titre)),
              ],
            ),
            const SizedBox(height: 14),
            Text(texte, style: Typo.corps),
            const SizedBox(height: 22),
            BoutonPrincipal(
              texte: "J'ai compris",
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Petite icône (i) qui ouvre une explication.
class AideInfo extends StatelessWidget {
  final String titre;
  final String texte;
  final Color couleur;

  const AideInfo({
    super.key,
    required this.titre,
    required this.texte,
    this.couleur = Couleurs.bleu,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: 'Informations',
        icon: Icon(Icons.info_outline_rounded, size: 20, color: couleur),
        onPressed: () => afficherAide(context, titre, texte),
      );
}
