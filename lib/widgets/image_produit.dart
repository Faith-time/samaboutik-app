import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/produit_provider.dart';

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

/// Vignette d'un produit retrouvé à partir de son id (ou de son nom à défaut).
///
/// Sert partout où l'API ne renvoie pas l'URL de la photo (stock, classement,
/// lignes de vente, achats…) : la photo est lue dans la liste des produits,
/// chargée une seule fois si besoin. Sans photo, [repli] s'affiche.
class VignetteProduit extends StatefulWidget {
  final int? produitId;
  final String? nom;
  final double taille;
  final Widget repli;

  const VignetteProduit({
    super.key,
    this.produitId,
    this.nom,
    required this.repli,
    this.taille = 48,
  });

  @override
  State<VignetteProduit> createState() => _VignetteProduitState();
}

class _VignetteProduitState extends State<VignetteProduit> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = context.read<ProduitProvider>();
      if (p.produits.isEmpty && !p.chargement && p.erreur == null) p.charger();
    });
  }

  String? _url(List produits) {
    final id = widget.produitId;
    if (id != null) {
      for (final p in produits) {
        if (p.id == id) return p.imageUrl as String?;
      }
    }
    final nom = widget.nom?.trim().toLowerCase();
    if (nom != null && nom.isNotEmpty) {
      for (final p in produits) {
        if ((p.nom as String).trim().toLowerCase() == nom) {
          return p.imageUrl as String?;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final produits = context.watch<ProduitProvider>().produits;
    return ImageProduit(
      url: _url(produits),
      taille: widget.taille,
      repli: widget.repli,
    );
  }
}
