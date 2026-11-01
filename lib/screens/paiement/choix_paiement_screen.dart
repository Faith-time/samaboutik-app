import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../models/vente.dart';
import '../../providers/paiement_provider.dart';
import '../../providers/vente_provider.dart';
import '../../services/stockage_service.dart';
import '../../widgets/aide_info.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import '../ventes/recu_screen.dart';
import 'paiement_mobile_screen.dart';
import 'qr_lightning_screen.dart';

class _Option {
  final String methode;
  final String texte;
  final bool aide;
  const _Option(this.methode, this.texte, {this.aide = false});
}

/// Le commerçant choisit comment le client paie.
class ChoixPaiementScreen extends StatefulWidget {
  final Vente vente;
  const ChoixPaiementScreen({super.key, required this.vente});

  @override
  State<ChoixPaiementScreen> createState() => _ChoixPaiementScreenState();
}

class _ChoixPaiementScreenState extends State<ChoixPaiementScreen> {
  bool _occupe = false;

  static const _options = [
    _Option('especes', TextesAide.paiementEspeces),
    _Option('wave', TextesAide.paiementMobile),
    _Option('orange_money', TextesAide.paiementMobile),
    _Option('free_money', TextesAide.paiementMobile),
    _Option('lightning', TextesAide.paiementBitcoin, aide: true),
  ];

  void _message(String texte) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(texte)));

  Future<void> _choisir(String methode) async {
    if (_occupe) return;
    final paiements = context.read<PaiementProvider>();
    final vente = widget.vente;

    if (methode == 'especes') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Paiement en espèces'),
          content: Text('Avez-vous reçu ${formatFcfa(vente.totalFcfa)} ?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Non')),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Oui, reçu')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }

    if (methode == 'lightning' && !await StockageService.premierPaiementVu()) {
      if (!mounted) return;
      await afficherAide(context, TextesAide.premierPaiementTitre,
          TextesAide.premierPaiementTexte);
      await StockageService.marquerPremierPaiementVu();
      if (!mounted) return;
    }

    setState(() => _occupe = true);
    final p = await paiements.payer(vente.id, methode);
    if (!mounted) return;
    setState(() => _occupe = false);

    if (p == null) {
      _message(paiements.erreur ?? 'Une erreur est survenue.');
      return;
    }
    if (p.estPaye) {
      allerAuRecu(context, vente.id);
    } else if (methode == 'lightning') {
      aller(context, QrLightningScreen(vente: vente));
    } else {
      aller(context, PaiementMobileScreen(vente: vente));
    }
  }

  Future<void> _annulerVente() async {
    final ventes = context.read<VenteProvider>();
    final ok = await ventes.annuler(widget.vente.id);
    if (!mounted) return;
    if (ok) {
      ventes.charger();
      retourAccueil(context);
    } else {
      _message(ventes.erreur ?? 'Une erreur est survenue.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return EcranNeo(
      titre: 'Paiement',
      retour: true,
      defiler: true,
      bas: TextButton(
        onPressed: _occupe ? null : _annulerVente,
        child: const Text('Annuler la vente',
            style: TextStyle(color: Couleurs.erreur)),
      ),
      child: _occupe
          ? const SizedBox(height: 360, child: Chargement())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarteHero(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Montant à encaisser',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(formatFcfa(widget.vente.totalFcfa),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const TitreSection('Choisissez le moyen de paiement'),
                for (final o in _options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: CarteNeo(
                      padding: const EdgeInsets.all(14),
                      rayon: 20,
                      onTap: () => _choisir(o.methode),
                      child: Row(
                        children: [
                          IconeRonde(
                            icone: iconeMethode(o.methode),
                            couleur: couleurMethode(o.methode),
                            fond: fondMethode(o.methode),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  o.methode == 'lightning'
                                      ? 'Bitcoin (Lightning)'
                                      : nomMethode(o.methode),
                                  style: Typo.corps
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(o.texte, style: Typo.petit),
                              ],
                            ),
                          ),
                          if (o.aide)
                            const AideInfo(
                              titre: TextesAide.bulleBitcoinTitre,
                              texte: TextesAide.bulleBitcoinTexte,
                            )
                          else
                            const Icon(Icons.chevron_right_rounded,
                                color: Couleurs.texteDoux),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
