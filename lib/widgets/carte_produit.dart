import 'package:flutter/material.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/produit.dart';
import 'carte_neo.dart';
import 'composants_neo.dart';
import 'fond_neo.dart';

/// Ligne produit. Avec [quantite], affiche un sélecteur (+ / -) pour le panier.
class CarteProduit extends StatelessWidget {
  final Produit produit;
  final int? quantite;
  final VoidCallback? onTap;
  final VoidCallback? onAjouter;
  final VoidCallback? onRetirer;

  const CarteProduit({
    super.key,
    required this.produit,
    this.quantite,
    this.onTap,
    this.onAjouter,
    this.onRetirer,
  });

  @override
  Widget build(BuildContext context) {
    final q = quantite ?? 0;
    return CarteNeo(
      padding: const EdgeInsets.all(14),
      rayon: 20,
      onTap: onTap ?? (quantite != null ? onAjouter : null),
      child: Row(
        children: [
          IconeRonde(
            icone: Icons.inventory_2_outlined,
            fond: produit.actif ? Couleurs.bleuClair : Couleurs.champ,
            couleur: produit.actif ? Couleurs.bleu : Couleurs.texteDoux,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(produit.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Typo.corps.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  produit.actif
                      ? formatFcfa(produit.prixFcfa)
                      : '${formatFcfa(produit.prixFcfa)} · désactivé',
                  style: Typo.doux,
                ),
              ],
            ),
          ),
          if (quantite == null)
            const Icon(Icons.chevron_right_rounded, color: Couleurs.texteDoux)
          else if (q == 0)
            BoutonRond(icone: Icons.add_rounded, taille: 38, onTap: onAjouter)
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BoutonRond(
                    icone: Icons.remove_rounded, taille: 34, onTap: onRetirer),
                SizedBox(
                  width: 34,
                  child: Text('$q',
                      textAlign: TextAlign.center, style: Typo.sousTitre),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: Couleurs.bleu, shape: BoxShape.circle),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onAjouter,
                      child: const Center(
                          child:
                              Icon(Icons.add_rounded, size: 20, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
