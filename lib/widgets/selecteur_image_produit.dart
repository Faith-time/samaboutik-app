import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme.dart';

/// Zone « photo du produit » du formulaire : prendre une photo, choisir dans la galerie, retirer.
class SelecteurImageProduit extends StatelessWidget {
  /// Photo déjà enregistrée sur le serveur (modification d'un produit).
  final String? urlActuelle;

  /// Nouvelle photo choisie, pas encore envoyée.
  final String? cheminLocal;

  final ValueChanged<String> onChoisie;
  final VoidCallback onRetirer;

  const SelecteurImageProduit({
    super.key,
    required this.urlActuelle,
    required this.cheminLocal,
    required this.onChoisie,
    required this.onRetirer,
  });

  bool get _aUneImage => cheminLocal != null || urlActuelle != null;

  Future<void> _choisir(BuildContext context, ImageSource source) async {
    final messager = ScaffoldMessenger.of(context);
    try {
      final fichier = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024, // réduit le poids : important avec une connexion mobile
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (fichier != null) onChoisie(fichier.path);
    } catch (_) {
      messager.showSnackBar(const SnackBar(
          content: Text("Impossible d'ouvrir l'appareil photo ou la galerie. "
              "Vérifiez les autorisations de l'application.")));
    }
  }

  void _ouvrirMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: Couleurs.bleu),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _choisir(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Couleurs.bleu),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.of(ctx).pop();
                _choisir(context, ImageSource.gallery);
              },
            ),
            if (_aUneImage)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Couleurs.erreur),
                title: const Text('Retirer la photo',
                    style: TextStyle(color: Couleurs.erreur)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onRetirer();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget contenu;
    if (cheminLocal != null) {
      contenu = Image.file(File(cheminLocal!), fit: BoxFit.cover);
    } else if (urlActuelle != null) {
      contenu = CachedNetworkImage(
        imageUrl: urlActuelle!,
        fit: BoxFit.cover,
        placeholder: (_, __) => const SizedBox.shrink(),
        errorWidget: (_, __, ___) => _vide(),
      );
    } else {
      contenu = _vide();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () => _ouvrirMenu(context),
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Couleurs.champ,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Couleurs.ligne, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: contenu,
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _ouvrirMenu(context),
          icon: Icon(_aUneImage ? Icons.edit_outlined : Icons.add_a_photo_outlined,
              size: 18),
          label: Text(_aUneImage ? 'Changer la photo' : 'Ajouter une photo'),
        ),
      ],
    );
  }

  Widget _vide() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 36, color: Couleurs.texteDoux),
            SizedBox(height: 6),
            Text('Photo du produit', style: Typo.petit),
          ],
        ),
      );
}
