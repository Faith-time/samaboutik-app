import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
import 'montrer_client_screen.dart';
import 'suivi_paiement.dart';

/// Paiement Bitcoin (Lightning) : QR code, montant en FCFA et en sats, compte à rebours.
class QrLightningScreen extends StatefulWidget {
  final Vente vente;
  const QrLightningScreen({super.key, required this.vente});

  @override
  State<QrLightningScreen> createState() => _QrLightningScreenState();
}

class _QrLightningScreenState extends State<QrLightningScreen>
    with SuiviPaiement<QrLightningScreen> {
  bool _occupe = false;

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

  Future<void> _nouveauCode() async {
    setState(() => _occupe = true);
    final provider = context.read<PaiementProvider>();
    final p = await provider.payer(widget.vente.id, 'lightning');
    if (!mounted) return;
    setState(() => _occupe = false);
    if (p == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.erreur ?? 'Une erreur est survenue.')));
      return;
    }
    reinitialiserDecompte();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PaiementProvider>().paiement;
    if (p == null || _occupe) {
      return const EcranNeo(
        titre: 'Paiement Bitcoin',
        retour: true,
        child: Chargement(),
      );
    }

    if (paiementExpire(p)) return _ecranProbleme(
      icone: Icons.timer_off_rounded,
      titre: TextesAide.expireTitre,
      texte: TextesAide.expireTexte,
      bouton: 'Créer un nouveau code',
    );
    if (paiementEchoue(p)) return _ecranProbleme(
      icone: Icons.error_outline_rounded,
      titre: TextesAide.echecTitre,
      texte: TextesAide.echecTexte,
      bouton: 'Réessayer',
    );

    return EcranNeo(
      titre: 'Paiement Bitcoin',
      retour: true,
      defiler: true,
      bas: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BoutonPrincipal(
            texte: 'Montrer au client',
            icone: Icons.qr_code_2_rounded,
            onPressed: () => aller(context, MontrerClientScreen(vente: widget.vente)),
          ),
          const SizedBox(height: 10),
          BoutonPrincipal(
            texte: 'Annuler',
            secondaire: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      child: Column(
        children: [
          const IconeRonde(
            icone: Icons.currency_bitcoin_rounded,
            couleur: Colors.white,
            fond: Couleurs.bitcoin,
            taille: 64,
          ),
          const SizedBox(height: 14),
          Text(formatFcfa(p.montantFcfa), style: Typo.montantGeant),
          if (p.montantSats != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('≈ ${formatSats(p.montantSats!)}', style: Typo.doux),
                const AideInfo(
                  titre: TextesAide.satsTitre,
                  texte: TextesAide.satsTexte,
                ),
              ],
            ),
          const SizedBox(height: 8),
          CarteNeo(
            padding: const EdgeInsets.all(18),
            child: (p.factureLightning == null || p.factureLightning!.isEmpty)
                ? const SizedBox(
                    height: 220,
                    child: Center(
                      child: Text("Le code n'est pas disponible.",
                          style: Typo.doux),
                    ),
                  )
                : QrImageView(
                    data: p.factureLightning!,
                    size: 230,
                    backgroundColor: Colors.white,
                  ),
          ),
          const SizedBox(height: 18),
          const Text(TextesAide.qrConsigne,
              textAlign: TextAlign.center, style: Typo.corps),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Couleurs.bleuClair,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 18, color: Couleurs.bleu),
                const SizedBox(width: 8),
                Text(
                  formatChrono(
                      restant ?? const Duration(minutes: TextesAide.dureeMinutes)),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Couleurs.bleu),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(TextesAide.qrCompteARebours,
              textAlign: TextAlign.center, style: Typo.petit),
          TextButton.icon(
            onPressed: () => afficherAide(
                context, TextesAide.qrQuestionTitre, TextesAide.qrQuestionTexte),
            icon: const Icon(Icons.info_outline_rounded, size: 18),
            label: const Text("C'est quoi un code QR ?"),
          ),
        ],
      ),
    );
  }

  Widget _ecranProbleme({
    required IconData icone,
    required String titre,
    required String texte,
    required String bouton,
  }) =>
      EcranNeo(
        titre: 'Paiement Bitcoin',
        retour: true,
        bas: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BoutonPrincipal(texte: bouton, onPressed: _nouveauCode),
            const SizedBox(height: 10),
            BoutonPrincipal(
              texte: 'Changer de moyen de paiement',
              secondaire: true,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
        child: EtatVide(icone: icone, titre: titre, texte: texte),
      );
}
