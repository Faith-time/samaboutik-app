import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/formatters.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../models/vente.dart';
import '../../providers/paiement_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/fond_neo.dart';

/// Grand code QR à tourner vers le client, avec les étapes pour payer.
/// Le suivi du paiement continue sur l'écran précédent, qui ouvrira le reçu.
class MontrerClientScreen extends StatefulWidget {
  final Vente vente;
  const MontrerClientScreen({super.key, required this.vente});

  @override
  State<MontrerClientScreen> createState() => _MontrerClientScreenState();
}

class _MontrerClientScreenState extends State<MontrerClientScreen> {
  Timer? _minuteur;
  Duration? _restant;

  @override
  void initState() {
    super.initState();
    _minuteur = Timer.periodic(const Duration(seconds: 1), (_) {
      final p = context.read<PaiementProvider>().paiement;
      if (mounted && p?.expireLe != null) {
        setState(() => _restant = p!.expireLe!.difference(DateTime.now()));
      }
    });
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PaiementProvider>().paiement;
    final facture = p?.factureLightning;
    final expire = _restant != null && _restant!.isNegative;

    return EcranNeo(
      titre: 'Payer avec Bitcoin',
      retour: true,
      defiler: true,
      bas: BoutonPrincipal(
        texte: 'Retour',
        secondaire: true,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      child: Column(
        children: [
          const Text(TextesAide.montrerClientTitre,
              textAlign: TextAlign.center, style: Typo.titreEcran),
          const SizedBox(height: 10),
          Text(formatFcfa(widget.vente.totalFcfa), style: Typo.montantGeant),
          if (p?.montantSats != null)
            Text('soit ${formatSats(p!.montantSats!)}', style: Typo.doux),
          const SizedBox(height: 18),
          CarteNeo(
            padding: const EdgeInsets.all(20),
            child: (facture == null || facture.isEmpty || expire)
                ? SizedBox(
                    height: 240,
                    child: Center(
                      child: Text(
                        expire
                            ? TextesAide.expireTitre
                            : "Le code n'est pas disponible.",
                        style: Typo.sousTitre,
                      ),
                    ),
                  )
                : QrImageView(
                    data: facture,
                    size: 260,
                    backgroundColor: Colors.white,
                  ),
          ),
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
                      _restant ?? const Duration(minutes: TextesAide.dureeMinutes)),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Couleurs.bleu),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CarteNeo(
            rayon: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < TextesAide.montrerClientEtapes.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Couleurs.bleuClair, shape: BoxShape.circle),
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Couleurs.bleu,
                                  fontSize: 13)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(TextesAide.montrerClientEtapes[i],
                                style: Typo.corps),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(TextesAide.montrerClientNote,
              textAlign: TextAlign.center, style: Typo.petit),
        ],
      ),
    );
  }
}
