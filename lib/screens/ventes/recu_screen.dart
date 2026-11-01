import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../models/vente.dart';
import '../../providers/tableau_bord_provider.dart';
import '../../providers/vente_provider.dart';
import '../../services/api_client.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import 'detail_vente_screen.dart';

/// Va au reçu et retire tous les écrans de la vente (il ne reste que l'accueil).
void allerAuRecu(BuildContext context, int venteId) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => RecuScreen(venteId: venteId)),
    (route) => route.isFirst,
  );
}

String _libelleMethode(String m) {
  switch (m) {
    case 'especes':
      return 'en espèces';
    case 'lightning':
      return 'en Bitcoin via Lightning';
    case 'wave':
      return 'par Wave';
    case 'orange_money':
      return 'par Orange Money';
    case 'free_money':
      return 'par Free Money';
    default:
      return '';
  }
}

class RecuScreen extends StatefulWidget {
  final int venteId;
  const RecuScreen({super.key, required this.venteId});

  @override
  State<RecuScreen> createState() => _RecuScreenState();
}

class _RecuScreenState extends State<RecuScreen> {
  Vente? _vente;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final ventes = context.read<VenteProvider>();
    final tableau = context.read<TableauBordProvider>();
    try {
      final v = await ventes.detail(widget.venteId);
      if (!mounted) return;
      setState(() => _vente = v);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erreur = ApiClient.messageErreur(e));
    }
    // L'accueil et l'historique se mettent à jour avec la nouvelle vente.
    tableau.charger();
    ventes.charger();
  }

  @override
  Widget build(BuildContext context) {
    final v = _vente;
    final paiement = v?.paiementPaye;

    Widget corps;
    if (_erreur != null) {
      corps = Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: MessageErreur(message: _erreur!)),
      );
    } else if (v == null) {
      corps = const Chargement();
    } else {
      corps = SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, valeur, enfant) =>
                  Transform.scale(scale: valeur, child: enfant),
              child: Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  color: Couleurs.succes,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Couleurs.succes.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 68),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Paiement réussi !', style: Typo.titreEcran),
            const SizedBox(height: 8),
            Text(
              '${formatFcfa(v.totalFcfa)} réglés ${_libelleMethode(v.methode)}'.trim(),
              textAlign: TextAlign.center,
              style: Typo.doux.copyWith(fontSize: 14.5),
            ),
            if (paiement != null && paiement.estLightning) ...[
              const SizedBox(height: 22),
              CarteNeo(
                rayon: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (paiement.montantSats != null)
                      Text(
                        'Payé en Bitcoin : ${formatSats(paiement.montantSats!)} (environ ${formatFcfa(paiement.montantFcfa)})',
                        style: Typo.corps.copyWith(fontWeight: FontWeight.w600),
                      ),
                    if (paiement.tauxBtcFcfa != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Prix du Bitcoin au moment du paiement : ${formatFcfa(paiement.tauxBtcFcfa!.round())}',
                        style: Typo.doux,
                      ),
                    ],
                    const SizedBox(height: 10),
                    const Text(TextesAide.recuBitcoin, style: Typo.doux),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) retourAccueil(context);
      },
      child: Scaffold(
        backgroundColor: Couleurs.fondHaut,
        body: FondNeo(
          child: Column(
            children: [
              Expanded(child: Center(child: corps)),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Column(
                  children: [
                    BoutonPrincipal(
                      texte: 'Voir la vente',
                      onPressed: v == null
                          ? null
                          : () => aller(context, DetailVenteScreen(venteId: v.id)),
                    ),
                    const SizedBox(height: 12),
                    BoutonPrincipal(
                      texte: "Retour à l'accueil",
                      secondaire: true,
                      onPressed: () => retourAccueil(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
