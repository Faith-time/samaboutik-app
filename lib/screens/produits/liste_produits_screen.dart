import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/stock_outils.dart';
import '../../core/theme.dart';
import '../../providers/produit_provider.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/image_produit.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../../widgets/stock_widgets.dart';
import '../stock/classement_screen.dart';
import '../stock/stock_screen.dart';
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
      if (!mounted) return;
      context.read<ProduitProvider>().charger();
      context.read<StockProvider>().charger();
    });
  }

  Future<void> _rafraichir() async {
    await Future.wait([
      context.read<ProduitProvider>().charger(),
      context.read<StockProvider>().charger(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProduitProvider>();
    final stock = context.watch<StockProvider>();
    void ouvrirFormulaire() => aller(context, const FormulaireProduitScreen());

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
        onRefresh: _rafraichir,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(2, 4, 2, 12),
          itemCount: p.produits.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) {
            if (i == 0) {
              return Row(
                children: [
                  Expanded(
                    child: BoutonPrincipal(
                      texte: 'Mon stock',
                      secondaire: true,
                      icone: Icons.inventory_rounded,
                      onPressed: () => aller(context, const StockScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BoutonPrincipal(
                      texte: 'Classement',
                      secondaire: true,
                      icone: Icons.leaderboard_rounded,
                      onPressed: () => aller(context, const ClassementScreen()),
                    ),
                  ),
                ],
              );
            }
            final produit = p.produits[i - 1];
            final s = stock.produit(produit.id);
            final suivi = s != null && s.suivreStock;
            return CarteNeo(
              rayon: 20,
              padding: const EdgeInsets.all(14),
              onTap: () => aller(context, FormulaireProduitScreen(produit: produit)),
              child: Row(
                children: [
                  ImageProduit(
                    url: produit.imageUrl,
                    taille: 56,
                    repli: IconeRonde(
                      icone: Icons.inventory_2_outlined,
                      couleur: suivi ? couleurStatutStock(s.statutStock) : Couleurs.bleu,
                      fond: suivi ? fondStatutStock(s.statutStock) : Couleurs.bleuClair,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(produit.nom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Typo.corps.copyWith(fontWeight: FontWeight.w700)),
                        Text(formatFcfa(produit.prixFcfa), style: Typo.petit),
                        if (suivi)
                          Text(
                            'Stock : ${texteUnites(s.stockActuel)}'
                            '${s.unitesParLot > 1 && s.lotsRestants != null ? ' (${texteLots(s.lotsRestants!)})' : ''}',
                            style: Typo.petit,
                          ),
                      ],
                    ),
                  ),
                  if (!produit.actif)
                    PastilleStatut(
                        libelle: 'Inactif',
                        couleur: Couleurs.texteDoux,
                        fond: Couleurs.champ)
                  else if (suivi)
                    PastilleStock(s.statutStock)
                  else
                    const Icon(Icons.chevron_right_rounded,
                        color: Couleurs.texteDoux),
                ],
              ),
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
