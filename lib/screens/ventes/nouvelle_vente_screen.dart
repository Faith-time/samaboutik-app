import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/panier_provider.dart';
import '../../providers/produit_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/vente_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_produit.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../paiement/choix_paiement_screen.dart';
import '../produits/formulaire_produit_screen.dart';

/// Le commerçant choisit les produits et les quantités, puis passe au paiement.
/// Le stock restant est affiché, et on ne peut pas vendre plus que ce qu'il reste.
class NouvelleVenteScreen extends StatefulWidget {
  const NouvelleVenteScreen({super.key});

  @override
  State<NouvelleVenteScreen> createState() => _NouvelleVenteScreenState();
}

class _NouvelleVenteScreenState extends State<NouvelleVenteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PanierProvider>().vider();
      context.read<ProduitProvider>().charger();
      context.read<StockProvider>().charger();
    });
  }

  Future<void> _continuer() async {
    final panier = context.read<PanierProvider>();
    final ventes = context.read<VenteProvider>();
    final vente = await ventes.creer(panier.lignesApi);
    if (!mounted) return;
    if (vente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ventes.erreur ?? 'Une erreur est survenue.')));
      // Le stock a peut-être changé : on le recharge
      context.read<StockProvider>().charger();
      return;
    }
    panier.vider();
    await aller(context, ChoixPaiementScreen(vente: vente));
    // Au retour, le stock a peut-être baissé (paiement confirmé)
    if (mounted) context.read<StockProvider>().charger();
  }

  @override
  Widget build(BuildContext context) {
    final produits = context.watch<ProduitProvider>();
    final panier = context.watch<PanierProvider>();
    final ventes = context.watch<VenteProvider>();
    final stock = context.watch<StockProvider>();
    final actifs = produits.actifs;

    Widget contenu;
    if (produits.chargement && produits.produits.isEmpty) {
      contenu = const Chargement();
    } else if (produits.erreur != null && produits.produits.isEmpty) {
      contenu = MessageErreur(
          message: produits.erreur!,
          onReessayer: () => context.read<ProduitProvider>().charger());
    } else if (actifs.isEmpty) {
      contenu = EtatVide(
        icone: Icons.inventory_2_outlined,
        titre: 'Aucun produit à vendre',
        texte: "Ajoutez d'abord vos produits pour pouvoir enregistrer une vente.",
        libelleAction: 'Ajouter un produit',
        onAction: () => aller(context, const FormulaireProduitScreen()),
      );
    } else {
      contenu = ListView.separated(
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 12),
        itemCount: actifs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final p = actifs[i];
          final s = stock.produit(p.id);
          final restant = (s != null && s.suivreStock) ? s.stockActuel : null;
          final dansPanier = panier.quantite(p.id);

          String? info;
          Color infoCouleur = Couleurs.texteDoux;
          if (restant != null) {
            if (restant <= 0) {
              info = 'Épuisé';
              infoCouleur = Couleurs.erreur;
            } else {
              final reste = restant - dansPanier;
              info = 'Stock restant : $reste';
              if (s!.bas) infoCouleur = Couleurs.bitcoin;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarteProduit(
                produit: p,
                quantite: dansPanier,
                onAjouter: () {
                  if (restant != null && dansPanier >= restant) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(restant <= 0
                          ? '${p.nom} est épuisé.'
                          : 'Stock insuffisant : il ne reste que $restant ${p.nom}.'),
                    ));
                    return;
                  }
                  context.read<PanierProvider>().ajouter(p);
                },
                onRetirer: () => context.read<PanierProvider>().retirer(p),
              ),
              if (info != null)
                Padding(
                  padding: const EdgeInsets.only(left: 18, top: 4),
                  child: Text(info,
                      style: Typo.petit.copyWith(
                          color: infoCouleur, fontWeight: FontWeight.w600)),
                ),
            ],
          );
        },
      );
    }

    return EcranNeo(
      titre: 'Nouvelle vente',
      retour: true,
      bas: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    panier.nombreArticles == 0
                        ? 'Total'
                        : 'Total (${panier.nombreArticles} article${panier.nombreArticles > 1 ? 's' : ''})',
                    style: Typo.doux,
                  ),
                ),
                Text(formatFcfa(panier.total), style: Typo.montant),
              ],
            ),
          ),
          BoutonPrincipal(
            texte: 'Continuer',
            icone: Icons.arrow_forward_rounded,
            chargement: ventes.chargement,
            onPressed: panier.vide ? null : _continuer,
          ),
        ],
      ),
      child: contenu,
    );
  }
}
