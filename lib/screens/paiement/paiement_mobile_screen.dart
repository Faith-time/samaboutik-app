import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../models/vente.dart';
import '../../providers/paiement_provider.dart';
import '../../widgets/aide_info.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import 'attente_paiement_screen.dart';
import 'suivi_paiement.dart';

/// Paiement Wave, Orange Money ou Free Money : lien ou QR code de paiement.
class PaiementMobileScreen extends StatefulWidget {
  final Vente vente;
  const PaiementMobileScreen({super.key, required this.vente});

  @override
  State<PaiementMobileScreen> createState() => _PaiementMobileScreenState();
}

class _PaiementMobileScreenState extends State<PaiementMobileScreen>
    with SuiviPaiement<PaiementMobileScreen> {
  @override
  Vente get venteSuivie => widget.vente;

  @override
  void initState() {
    super.initState();
    demarrerSuivi();
  }

  @override
  void dispose() {
    arreterSuivi();
    super.dispose();
  }

  Future<void> _ouvrir(String url) async {
    await aller(context, PagePaiementWeb(url: url));
    if (!mounted) return;
    // Le client a fini : on passe à l'écran d'attente.
    await remplacerPar(context, AttentePaiementScreen(vente: widget.vente));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PaiementProvider>().paiement;
    if (p == null) {
      return const EcranNeo(titre: 'Paiement', retour: true, child: Chargement());
    }
    final lien = p.lienPaiement;
    final nom = nomMethode(p.methode);

    if (paiementEchoue(p)) {
      return EcranNeo(
        titre: nom,
        retour: true,
        bas: BoutonPrincipal(
          texte: 'Changer de moyen de paiement',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        child: const EtatVide(
          icone: Icons.error_outline_rounded,
          titre: TextesAide.echecTitre,
          texte: TextesAide.echecTexte,
        ),
      );
    }

    return EcranNeo(
      titre: nom,
      retour: true,
      defiler: true,
      bas: BoutonPrincipal(
        texte: 'Ouvrir le paiement',
        icone: Icons.open_in_new_rounded,
        onPressed: (lien == null || lien.isEmpty) ? null : () => _ouvrir(lien),
      ),
      child: Column(
        children: [
          IconeRonde(
            icone: Icons.smartphone_rounded,
            couleur: Colors.white,
            fond: Couleurs.bleu,
            taille: 64,
          ),
          const SizedBox(height: 14),
          Text(formatFcfa(p.montantFcfa), style: Typo.montantGeant),
          const SizedBox(height: 4),
          const Text(TextesAide.mobileTitre, style: Typo.sousTitre),
          const SizedBox(height: 14),
          CarteNeo(
            padding: const EdgeInsets.all(18),
            child: (lien == null || lien.isEmpty)
                ? const SizedBox(
                    height: 200,
                    child: Center(
                        child: Text("Le lien n'est pas disponible.",
                            style: Typo.doux)),
                  )
                : QrImageView(
                    data: lien,
                    size: 210,
                    backgroundColor: Colors.white,
                  ),
          ),
          const SizedBox(height: 16),
          const Text(TextesAide.mobileTexte,
              textAlign: TextAlign.center, style: Typo.doux),
          const SizedBox(height: 6),
          const Text(TextesAide.mobileTest,
              textAlign: TextAlign.center, style: Typo.petit),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 10),
              const Text(TextesAide.attenteTitre, style: Typo.doux),
              const AideInfo(
                titre: TextesAide.qrQuestionTitre,
                texte: TextesAide.qrQuestionTexte,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Page de paiement du prestataire, affichée dans l'application.
class PagePaiementWeb extends StatefulWidget {
  final String url;
  const PagePaiementWeb({super.key, required this.url});

  @override
  State<PagePaiementWeb> createState() => _PagePaiementWebState();
}

class _PagePaiementWebState extends State<PagePaiementWeb> {
  late final WebViewController _controleur;

  @override
  void initState() {
    super.initState();
    _controleur = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) => EcranNeo(
        titre: 'Paiement',
        retour: true,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: WebViewWidget(controller: _controleur),
        ),
      );
}
