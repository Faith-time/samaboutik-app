import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/stock.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/bouton_principal.dart';
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
        libelleAction: 'Enregistrer un achat',
        onAction: () => aller(context, const ReapprovisionnerScreen()),
      );
    } else {
      final total = s.achats.fold<int>(0, (t, a) => t + a.depenseFcfa);
      final n = s.achats.length;
      contenu = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarteHero(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),

                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_basket_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total dépensé en achats',
                          style: TextStyle(color: Colors.white70, fontSize: 14.5)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(formatFcfa(total),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 4),
                      Text('$n achat${n > 1 ? 's' : ''} enregistré${n > 1 ? 's' : ''}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          for (final a in s.achats)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
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
      bas: s.achats.isEmpty
          ? null
          : BoutonPrincipal(
        texte: 'Enregistrer un achat',
        icone: Icons.add_shopping_cart_rounded,
        onPressed: () => aller(context, const ReapprovisionnerScreen()),
      ),
      child: contenu,
    );
  }
}

const _palette = <Color>[
  Color(0xFF2358D8),
  Color(0xFFF7931A),
  Color(0xFF22A55B),
  Color(0xFF7C4DFF),
  Color(0xFFE91E63),

  Color(0xFF00ACC1),
  Color(0xFFFF7043),
];

Color _couleurProduit(String nom) {
  var somme = 0;
  for (final c in nom.codeUnits) {
    somme += c;
  }
  return _palette[somme % _palette.length];
}

class _CarteAchat extends StatelessWidget {
  final Approvisionnement achat;
  const _CarteAchat({required this.achat});

  @override
  Widget build(BuildContext context) {
    final a = achat;
    final titre = (a.fournisseur == null || a.fournisseur!.isEmpty)
        ? 'Achat n°${a.id}'
        : a.fournisseur!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: ombresNeo,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: Colors.white,

          child: Column(
            children: [
              // En-tête bleu : qui, quand, combien
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Couleurs.bleu, Couleurs.bleuFonce],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800)),
                          if (a.creeLe != null)
                            Text(formatDateHeure(a.creeLe!),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total',
                            style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                        Text(formatFcfa(a.depenseFcfa),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
              // Les produits achetés
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                child: Column(
                  children: [
                    for (var i = 0; i < a.lignes.length; i++) ...[

                      if (i > 0) const Divider(height: 1),
                      _LigneAchatProduit(ligne: a.lignes[i]),
                    ],
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

class _LigneAchatProduit extends StatelessWidget {
  final LigneAppro ligne;
  const _LigneAchatProduit({required this.ligne});

  @override
  Widget build(BuildContext context) {
    final l = ligne;
    final c = _couleurProduit(l.nomProduit);
    final initiale = l.nomProduit.isEmpty ? '?' : l.nomProduit[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,

            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(initiale,
                style: TextStyle(color: c, fontSize: 21, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.nomProduit,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  '${l.nbLots} paquet${l.nbLots > 1 ? 's' : ''} de ${l.unitesParLot}'
                      ' = ${l.unites} unités',
                  style: const TextStyle(
                      fontSize: 13.5, height: 1.35, color: Couleurs.texteDoux),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatFcfa(l.nbLots * l.prixLotFcfa),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Couleurs.bleuClair,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${formatFcfa(l.coutUnitaireFcfa.round())} / unité',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: Couleurs.bleu)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}