import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../models/vente.dart';
import '../../providers/paiement_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import 'suivi_paiement.dart';

/// « En attente du paiement » : l'écran change tout seul dès que le serveur confirme.
class AttentePaiementScreen extends StatefulWidget {
  final Vente vente;
  const AttentePaiementScreen({super.key, required this.vente});

  @override
  State<AttentePaiementScreen> createState() => _AttentePaiementScreenState();
}

class _AttentePaiementScreenState extends State<AttentePaiementScreen>
    with SuiviPaiement<AttentePaiementScreen> {
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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PaiementProvider>().paiement;
    final echec = p != null && (paiementEchoue(p) || paiementExpire(p));

    return EcranNeo(
      titre: 'Paiement',
      retour: true,
      bas: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!echec)
            BoutonPrincipal(
              texte: 'Vérifier maintenant',
              icone: Icons.refresh_rounded,
              onPressed: () => context.read<PaiementProvider>().rafraichir(),
            ),
          if (!echec) const SizedBox(height: 10),
          BoutonPrincipal(
            texte: 'Changer de moyen de paiement',
            secondaire: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      child: Center(
        child: echec
            ? const EtatVide(
                icone: Icons.error_outline_rounded,
                titre: TextesAide.echecTitre,
                texte: TextesAide.echecTexte,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 84,
                    height: 84,
                    child: CircularProgressIndicator(
                        strokeWidth: 5, color: Couleurs.bleu),
                  ),
                  const SizedBox(height: 28),
                  const Text(TextesAide.attenteTitre, style: Typo.titreEcran),
                  const SizedBox(height: 10),
                  const Text(TextesAide.attenteTexte,
                      textAlign: TextAlign.center, style: Typo.doux),
                ],
              ),
      ),
    );
  }
}
