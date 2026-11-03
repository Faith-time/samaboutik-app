import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/stock.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import 'reapprovisionner_screen.dart';

/// Historique des achats faits chez les fournisseurs.
class HistoriqueAchatsScreen extends StatefulWidget {
  const HistoriqueAchatsScreen({super.key});

  @override
  State<HistoriqueAchatsScreen> createState() => _HistoriqueAchatsScreenState();
}

class _HistoriqueAchatsScreenState extends State<HistoriqueAchatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StockProvider>().chargerAchats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<StockProvider>();

    Widget contenu;
    if (s.erreurAchats != null && s.achats.isEmpty) {
      contenu = MessageErreur(
          message: s.erreurAchats!,
          onReessayer: () => context.read<StockProvider>().chargerAchats());
    } else if (s.chargementAchats && s.achats.isEmpty) {
      contenu = const SizedBox(height: 260, child: Chargement());
    } else if (s.achats.isEmpty) {
      contenu = EtatVide(
        icone: Icons.shopping_basket_outlined,
        titre: 'Aucun achat enregistré',
        texte: 'Enregistrez ce que vous achetez chez votre fournisseur : '
            'votre stock et votre bénéfice seront calculés pour vous.',
        libelleAction: 'Réapprovisionner',
        onAction: () => aller(context, const ReapprovisionnerScreen()),
      );
    } else {
      contenu = Column(
        children: [
          for (final a in s.achats)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _CarteAchat(achat: a),
            ),
        ],
      );
    }

    return EcranNeo(
      titre: 'Mes achats',
      retour: true,
      defiler: true,
      onRefresh: () => context.read<StockProvider>().chargerAchats(),
      child: contenu,
    );
  }
}

class _CarteAchat extends StatelessWidget {
  final Approvisionnement achat;
  const _CarteAchat({required this.achat});

  @override
  Widget build(BuildContext context) {
    final a = achat;
    return CarteNeo(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (a.fournisseur == null || a.fournisseur!.isEmpty)
                          ? 'Achat n°${a.id}'
                          : a.fournisseur!,
                      style: Typo.sousTitre,
                    ),
                    if (a.creeLe != null)
                      Text(formatDateHeure(a.creeLe!), style: Typo.petit),
                  ],
                ),
              ),
              Text(formatFcfa(a.depenseFcfa), style: Typo.montant),
            ],
          ),
          const Divider(height: 24),
          for (final l in a.lignes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.nomProduit,
                            style: Typo.corps.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          '${l.nbLots} × ${l.unitesParLot} = ${l.unites} unités · '
                          '${formatFcfa(l.coutUnitaireFcfa.round())} l\'unité',
                          style: Typo.petit,
                        ),
                      ],
                    ),
                  ),
                  Text(formatFcfa(l.nbLots * l.prixLotFcfa), style: Typo.corps),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
