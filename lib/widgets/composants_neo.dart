import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'carte_neo.dart';
import 'bouton_principal.dart';

/// Pastille ronde avec une icône.
class IconeRonde extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final Color fond;
  final double taille;

  const IconeRonde({
    super.key,
    required this.icone,
    this.couleur = Couleurs.bleu,
    this.fond = Couleurs.bleuClair,
    this.taille = 44,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: taille,
        height: taille,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
        child: Icon(icone, color: couleur, size: taille * 0.5),
      );
}

/// Logo SamaBoutik : sac bleu arrondi.
class LogoSamaBoutik extends StatelessWidget {
  final double taille;
  const LogoSamaBoutik({super.key, this.taille = 76});

  @override
  Widget build(BuildContext context) => Container(
        width: taille,
        height: taille,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(taille * 0.3),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Couleurs.bleu, Couleurs.bleuFonce],
          ),
          boxShadow: [
            BoxShadow(
              color: Couleurs.bleu.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(Icons.shopping_bag_rounded,
            color: Colors.white, size: taille * 0.52),
      );
}

/// Grande carte bleu foncé (ex. « Ventes du jour »).
class CarteHero extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const CarteHero(
      {super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) => CarteNeo(
        padding: padding,
        degrade: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Couleurs.bleuMoyen, Couleurs.bleuFonce],
        ),
        child: child,
      );
}

/// Petite carte de statistique (icône, titre, valeur, sous-titre).
class CarteStat extends StatelessWidget {
  final IconData icone;
  final Color couleurIcone;
  final Color fondIcone;
  final String titre;
  final String valeur;
  final String? sousTitre;

  const CarteStat({
    super.key,
    required this.icone,
    required this.titre,
    required this.valeur,
    this.sousTitre,
    this.couleurIcone = Couleurs.bleu,
    this.fondIcone = Couleurs.bleuClair,
  });

  @override
  Widget build(BuildContext context) => CarteNeo(
        padding: const EdgeInsets.all(14),
        rayon: 22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconeRonde(icone: icone, couleur: couleurIcone, fond: fondIcone, taille: 36),
            const SizedBox(height: 10),
            Text(titre, style: Typo.petit),
            const SizedBox(height: 2),
            Text(valeur,
                style: Typo.montant.copyWith(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            if (sousTitre != null) Text(sousTitre!, style: Typo.petit),
          ],
        ),
      );
}

/// Ligne de menu avec icône et flèche (profil, paramètres...).
class LigneMenu extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String? sousTitre;
  final VoidCallback? onTap;

  const LigneMenu({
    super.key,
    required this.icone,
    required this.titre,
    this.sousTitre,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              IconeRonde(icone: icone, taille: 38),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titre, style: Typo.corps.copyWith(fontWeight: FontWeight.w600)),
                    if (sousTitre != null) Text(sousTitre!, style: Typo.petit),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Couleurs.texteDoux),
            ],
          ),
        ),
      );
}

/// Pastille de statut (Payée, En attente...).
class PastilleStatut extends StatelessWidget {
  final String libelle;
  final Color couleur;
  final Color fond;
  const PastilleStatut(
      {super.key, required this.libelle, required this.couleur, required this.fond});

  /// Pastille selon le statut d'une vente.
  factory PastilleStatut.vente(String statut) {
    switch (statut) {
      case 'payee':
        return const PastilleStatut(
            libelle: 'Payée', couleur: Couleurs.succes, fond: Couleurs.succesClair);
      case 'annulee':
        return const PastilleStatut(
            libelle: 'Annulée', couleur: Couleurs.erreur, fond: Couleurs.erreurClair);
      default:
        return const PastilleStatut(
            libelle: 'En attente',
            couleur: Couleurs.bitcoin,
            fond: Couleurs.bitcoinClair);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: fond, borderRadius: BorderRadius.circular(20)),
        child: Text(libelle,
            style: TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: couleur)),
      );
}

/// Titre de section, avec une action facultative à droite.
class TitreSection extends StatelessWidget {
  final String texte;
  final Widget? action;
  const TitreSection(this.texte, {super.key, this.action});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Row(
          children: [
            Expanded(child: Text(texte, style: Typo.titre)),
            if (action != null) action!,
          ],
        ),
      );
}

/// Écran vide : icône, message et bouton facultatif.
class EtatVide extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String texte;
  final String? libelleAction;
  final VoidCallback? onAction;

  const EtatVide({
    super.key,
    required this.icone,
    required this.titre,
    required this.texte,
    this.libelleAction,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconeRonde(icone: icone, taille: 84),
              const SizedBox(height: 20),
              Text(titre, style: Typo.titre, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(texte, style: Typo.doux, textAlign: TextAlign.center),
              if (libelleAction != null) ...[
                const SizedBox(height: 22),
                BoutonPrincipal(texte: libelleAction!, onPressed: onAction),
              ],
            ],
          ),
        ),
      );
}
