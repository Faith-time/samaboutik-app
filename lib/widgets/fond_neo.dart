import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Fond dégradé bleu très clair + zone sûre. Utilisé par tous les écrans.
class FondNeo extends StatelessWidget {
  final Widget child;
  const FondNeo({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Couleurs.fondHaut, Couleurs.fondBas],
          ),
        ),
        child: SafeArea(child: child),
      );
}

/// Petit bouton rond blanc (retour, aide, actions d'en-tête).
class BoutonRond extends StatelessWidget {
  final IconData icone;
  final VoidCallback? onTap;
  final double taille;

  const BoutonRond({super.key, required this.icone, this.onTap, this.taille = 44});

  @override
  Widget build(BuildContext context) => Container(
        width: taille,
        height: taille,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle, boxShadow: ombresDouces),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Center(child: Icon(icone, size: 20, color: Couleurs.texte)),
          ),
        ),
      );
}

/// Contenu d'un écran : en-tête (titre centré, retour) + contenu + zone de boutons fixe en bas.
class CorpsNeo extends StatelessWidget {
  final String? titre;
  final bool retour;
  final List<Widget> actions;
  final Widget child;
  final bool defiler;
  final EdgeInsets padding;
  final Widget? bas;
  final Future<void> Function()? onRefresh;

  const CorpsNeo({
    super.key,
    this.titre,
    this.retour = false,
    this.actions = const [],
    required this.child,
    this.defiler = false,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 20),
    this.bas,
    this.onRefresh,
  });

  Widget _entete(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(
          children: [
            retour
                ? BoutonRond(
                    icone: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  )
                : const SizedBox(width: 44),
            Expanded(
              child: Text(
                titre ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Typo.sousTitre.copyWith(fontSize: 17),
              ),
            ),
            actions.isEmpty
                ? const SizedBox(width: 44)
                : Row(mainAxisSize: MainAxisSize.min, children: actions),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget contenu = defiler
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            child: child,
          )
        : Padding(padding: padding, child: child);
    if (onRefresh != null && defiler) {
      contenu = RefreshIndicator(onRefresh: onRefresh!, child: contenu);
    }
    return Column(
      children: [
        if (titre != null || retour) _entete(context),
        Expanded(child: contenu),
        if (bas != null)
          Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 16), child: bas),
      ],
    );
  }
}

/// Écran complet (Scaffold + fond + CorpsNeo).
class EcranNeo extends StatelessWidget {
  final String? titre;
  final bool retour;
  final List<Widget> actions;
  final Widget child;
  final bool defiler;
  final EdgeInsets padding;
  final Widget? bas;
  final Future<void> Function()? onRefresh;
  final Widget? barreNavigation;

  const EcranNeo({
    super.key,
    this.titre,
    this.retour = false,
    this.actions = const [],
    required this.child,
    this.defiler = false,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 20),
    this.bas,
    this.onRefresh,
    this.barreNavigation,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Couleurs.fondHaut,
        bottomNavigationBar: barreNavigation,
        body: FondNeo(
          child: CorpsNeo(
            titre: titre,
            retour: retour,
            actions: actions,
            defiler: defiler,
            padding: padding,
            bas: bas,
            onRefresh: onRefresh,
            child: child,
          ),
        ),
      );
}
