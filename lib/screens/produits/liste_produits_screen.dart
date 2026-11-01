import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../providers/produit_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_produit.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import 'formulaire_produit_screen.dart';

class ListeProduitsScreen extends StatefulWidget {
  const ListeProduitsScreen({super.key});

  @override
  State<ListeProduitsScreen> createState() => _ListeProduitsScreenState();
}

class _ListeProduitsScreenState extends State<ListeProduitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProduitProvider>().charger();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProduitProvider>();
    final ouvrirFormulaire = () => aller(context, const FormulaireProduitScreen());

    Widget contenu;
    if (p.chargement && p.produits.isEmpty) {
      contenu = const Chargement();
    } else if (p.erreur != null && p.produits.isEmpty) {
      contenu = MessageErreur(
          message: p.erreur!,
          onReessayer: () => context.read<ProduitProvider>().charger());
    } else if (p.produits.isEmpty) {
      contenu = EtatVide(
        icone: Icons.inventory_2_outlined,
        titre: 'Aucun produit pour le moment',
        texte: 'Ajoutez vos produits pour pouvoir les vendre en quelques touches.',
        libelleAction: 'Ajouter un produit',
        onAction: ouvrirFormulaire,
      );
    } else {
      contenu = RefreshIndicator(
        onRefresh: () => context.read<ProduitProvider>().charger(),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(2, 4, 2, 12),
          itemCount: p.produits.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) {
            final produit = p.produits[i];
            return CarteProduit(
              produit: produit,
              onTap: () =>
                  aller(context, FormulaireProduitScreen(produit: produit)),
            );
          },
        ),
      );
    }

    return EcranNeo(
      titre: 'Mes produits',
      retour: true,
      bas: p.produits.isEmpty
          ? null
          : BoutonPrincipal(
              texte: 'Ajouter un produit',
              icone: Icons.add_rounded,
              onPressed: ouvrirFormulaire,
            ),
      child: contenu,
    );
  }
}
