import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Vignette d'un produit : sa photo si elle existe, sinon [repli] (souvent une icône).
class ImageProduit extends StatelessWidget {
  final String? url;
  final double taille;
  final Widget repli;

  const ImageProduit({
    super.key,
    required this.url,
    required this.repli,
    this.taille = 52,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return SizedBox(width: taille, height: taille, child: Center(child: repli));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: taille,
        height: taille,
        child: CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (_, __) => Container(color: Couleurs.champ),
          errorWidget: (_, __, ___) =>
              Container(color: Couleurs.champ, child: Center(child: repli)),
        ),
      ),
    );
  }
}
