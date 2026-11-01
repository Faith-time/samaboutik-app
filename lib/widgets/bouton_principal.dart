import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Bouton en pilule. Variantes : principal (bleu), secondaire (bleu clair), danger (rouge clair).
class BoutonPrincipal extends StatelessWidget {
  final String texte;
  final VoidCallback? onPressed;
  final bool chargement;
  final IconData? icone;
  final bool secondaire;
  final bool danger;

  const BoutonPrincipal({
    super.key,
    required this.texte,
    this.onPressed,
    this.chargement = false,
    this.icone,
    this.secondaire = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color fond = danger
        ? Couleurs.erreurClair
        : secondaire
            ? Couleurs.bleuClair
            : Couleurs.bleu;
    final Color couleurTexte = danger
        ? Couleurs.erreur
        : secondaire
            ? Couleurs.bleu
            : Colors.white;
    final actif = onPressed != null && !chargement;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: (secondaire || danger || !actif)
            ? null
            : [
                BoxShadow(
                  color: Couleurs.bleu.withValues(alpha: 0.32),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton(
          onPressed: actif ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: fond,
            foregroundColor: couleurTexte,
            disabledBackgroundColor: fond.withValues(alpha: 0.55),
            disabledForegroundColor: couleurTexte.withValues(alpha: 0.85),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: chargement
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: couleurTexte),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icone != null) ...[
                      Icon(icone, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(texte, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
