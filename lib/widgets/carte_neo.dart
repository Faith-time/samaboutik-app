import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Carte blanche néomorphique : le bloc de base de tous les écrans.
class CarteNeo extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double rayon;
  final Color couleur;
  final Gradient? degrade;
  final VoidCallback? onTap;
  final List<BoxShadow> ombres;

  const CarteNeo({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.rayon = 24,
    this.couleur = Colors.white,
    this.degrade,
    this.onTap,
    this.ombres = ombresNeo,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(rayon);
    return Container(
      decoration: BoxDecoration(
        color: degrade == null ? couleur : null,
        gradient: degrade,
        borderRadius: r,
        boxShadow: ombres,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: r,
        child: InkWell(
          borderRadius: r,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
