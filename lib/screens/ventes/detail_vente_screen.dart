import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../models/paiement.dart';
import '../../models/vente.dart';
import '../../providers/vente_provider.dart';
import '../../services/api_client.dart';
import '../../widgets/aide_info.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../paiement/choix_paiement_screen.dart';

class DetailVenteScreen extends StatefulWidget {
  final int venteId;
  const DetailVenteScreen({super.key, required this.venteId});

  @override
  State<DetailVenteScreen> createState() => _DetailVenteScreenState();
}

class _DetailVenteScreenState extends State<DetailVenteScreen> {
  Vente? _vente;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final ventes = context.read<VenteProvider>();
    try {
      final v = await ventes.detail(widget.venteId);
      if (!mounted) return;
      setState(() {
        _vente = v;
        _erreur = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erreur = ApiClient.messageErreur(e));
    }
  }

  Future<void> _annuler() async {
    final ventes = context.read<VenteProvider>();
    final ok = await ventes.annuler(widget.venteId);
    if (!mounted) return;
    if (ok) {
      ventes.charger();
      await _charger();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ventes.erreur ?? 'Une erreur est survenue.')));
    }
  }

  String _statutPaiement(Paiement p) {
    switch (p.statut) {
      case 'paye':
        return p.payeLe != null ? 'Payé le ${formatDateHeure(p.payeLe!)}' : 'Payé';
      case 'expire':
        return 'Expiré';
      case 'echoue':
        return 'Échoué';
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _vente;

    Widget contenu;
    if (_erreur != null && v == null) {
      contenu = MessageErreur(message: _erreur!, onReessayer: _charger);
    } else if (v == null) {
      contenu = const SizedBox(height: 300, child: Chargement());
    } else {
      contenu = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarteNeo(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text('Vente n°${v.id}', style: Typo.titre)),
                    PastilleStatut.vente(v.statut),
                  ],
                ),
                if (v.creeLe != null) ...[
                  const SizedBox(height: 4),
                  Text(formatDateHeure(v.creeLe!), style: Typo.doux),
                ],
                const Divider(height: 28),
                for (final l in v.lignes)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${l.quantite} × ${l.nomProduit}',
                              style: Typo.corps),
                        ),
                        Text(formatFcfa(l.sousTotal), style: Typo.corps),
                      ],
                    ),
                  ),
                const Divider(height: 28),
                Row(
                  children: [
                    const Expanded(child: Text('Total', style: Typo.sousTitre)),
                    Text(formatFcfa(v.totalFcfa), style: Typo.montant),
                  ],
                ),
              ],
            ),
          ),
          if (v.paiements.isNotEmpty) ...[
            const TitreSection('Paiements'),
            CarteNeo(
              child: Column(
                children: [
                  for (final p in v.paiements)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          IconeRonde(
                            icone: iconeMethode(p.methode),
                            couleur: couleurMethode(p.methode),
                            fond: fondMethode(p.methode),
                            taille: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nomMethode(p.methode),
                                    style: Typo.corps
                                        .copyWith(fontWeight: FontWeight.w600)),
                                Text(_statutPaiement(p), style: Typo.petit),
                                if (p.estLightning && p.montantSats != null)
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${formatSats(p.montantSats!)} · ${formatFcfa(p.montantFcfa)} au moment du paiement',
                                          style: Typo.petit,
                                        ),
                                      ),
                                      const AideInfo(
                                        titre: 'Valeur en FCFA',
                                        texte: TextesAide.historiqueBitcoinInfo,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Text(formatFcfa(p.montantFcfa), style: Typo.corps),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    return EcranNeo(
      titre: 'Détail de la vente',
      retour: true,
      defiler: true,
      onRefresh: _charger,
      bas: (v != null && v.estEnAttente)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BoutonPrincipal(
                  texte: 'Encaisser',
                  icone: Icons.payments_rounded,
                  onPressed: () async {
                    await aller(context, ChoixPaiementScreen(vente: v));
                    if (mounted) _charger();
                  },
                ),
                const SizedBox(height: 10),
                BoutonPrincipal(
                    texte: 'Annuler la vente', danger: true, onPressed: _annuler),
              ],
            )
          : null,
      child: contenu,
    );
  }
}
