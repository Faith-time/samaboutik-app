import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bouton_principal.dart';

class _Page {
  final String titre;
  final String texte;
  final IconData? icone; // null = l'illustration de la commerçante
  final Color couleur;
  const _Page(this.titre, this.texte,
      {this.icone, this.couleur = Couleurs.bleu});
}

/// Trois écrans d'accueil, affichés une seule fois (comme la maquette).
class BienvenueScreen extends StatefulWidget {
  const BienvenueScreen({super.key});

  @override
  State<BienvenueScreen> createState() => _BienvenueScreenState();
}

class _BienvenueScreenState extends State<BienvenueScreen> {
  final _controleur = PageController();
  int _page = 0;

  static const _pages = [
    _Page(
      'Gérez votre boutique en toute simplicité',
      'Recevez des paiements en Bitcoin, suivez vos ventes et développez votre activité.',
    ),
    _Page(TextesAide.bienvenue2Titre, TextesAide.bienvenue2Texte,
        icone: Icons.currency_bitcoin_rounded, couleur: Couleurs.bitcoin),
    _Page(TextesAide.bienvenue3Titre, TextesAide.bienvenue3Texte,
        icone: Icons.timer_outlined),
  ];

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  Future<void> _terminer() =>
      context.read<AuthProvider>().marquerBienvenueVue();

  void _suivant() {
    if (_page == _pages.length - 1) {
      _terminer();
    } else {
      _controleur.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final derniere = _page == _pages.length - 1;
    final bas = MediaQuery.of(context).padding.bottom;
    final page = _pages[_page];

    return Scaffold(
      backgroundColor: Couleurs.fondHaut,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Couleurs.fondHaut, Couleurs.fondBas],
          ),
        ),
        child: Column(
          children: [
            // Haut de l'écran : l'illustration (on peut balayer)
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controleur,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 40, 28, 10),
                        child: Center(
                          child: _pages[i].icone == null
                              ? Image.asset(
                                  'assets/images/illustration_bienvenue.png',
                                  fit: BoxFit.contain,
                                )
                              : Container(
                                  width: 190,
                                  height: 190,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: ombresNeo,
                                  ),
                                  child: Icon(_pages[i].icone,
                                      size: 92, color: _pages[i].couleur),
                                ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
                        child: TextButton(
                          onPressed: derniere ? null : _terminer,
                          child: Text(derniere ? '' : 'Passer'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bas de l'écran : panneau blanc arrondi avec texte, points et bouton
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, 30, 24, 20 + bas),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F2A55B8),
                    blurRadius: 30,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 160,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Column(
                        key: ValueKey(_page),
                        children: [
                          Text(page.titre,
                              textAlign: TextAlign.center,
                              style: Typo.titreEcran.copyWith(fontSize: 23)),
                          const SizedBox(height: 12),
                          Text(page.texte,
                              textAlign: TextAlign.center,
                              style: Typo.doux.copyWith(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page ? Couleurs.bleu : Couleurs.ligne,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  BoutonPrincipal(
                    texte: derniere ? 'Commencer →' : 'Suivant →',
                    onPressed: _suivant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
