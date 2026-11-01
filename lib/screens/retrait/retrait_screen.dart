import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/textes_aide.dart';
import '../../core/theme.dart';
import '../../providers/retrait_provider.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/champ_texte.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../../widgets/onglets_pilule.dart';

/// Retrait en FCFA : simulation, aucun argent ne bouge.
class RetraitScreen extends StatefulWidget {
  const RetraitScreen({super.key});

  @override
  State<RetraitScreen> createState() => _RetraitScreenState();
}

class _RetraitScreenState extends State<RetraitScreen> {
  static const _operateurs = ['wave', 'orange_money', 'free_money'];
  static const _libelles = ['Wave', 'Orange Money', 'Free Money'];

  final _formKey = GlobalKey<FormState>();
  final _montant = TextEditingController();
  int _operateur = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RetraitProvider>().charger();
    });
  }

  @override
  void dispose() {
    _montant.dispose();
    super.dispose();
  }

  Future<void> _retirer(int solde) async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<RetraitProvider>();
    final ok = await provider.retirer(int.parse(_montant.text), _operateurs[_operateur]);
    if (!mounted) return;
    if (ok) {
      _montant.clear();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Retrait simulé enregistré.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RetraitProvider>();
    final r = p.resume;
    final solde = r?.soldeFcfa ?? 0;

    return EcranNeo(
      titre: TextesAide.retraitTitre,
      retour: true,
      defiler: true,
      onRefresh: () => context.read<RetraitProvider>().charger(),
      bas: BoutonPrincipal(
        texte: 'Retirer',
        icone: Icons.account_balance_wallet_outlined,
        chargement: p.chargement && r != null,
        onPressed: r == null ? null : () => _retirer(solde),
      ),
      child: (r == null && p.erreur == null)
          ? const SizedBox(height: 300, child: Chargement())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarteNeo(
                  couleur: Couleurs.bleuClair,
                  ombres: const [],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Couleurs.bleu, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                          child:
                              Text(TextesAide.retraitTexte, style: Typo.doux)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (p.erreur != null && r == null)
                  MessageErreur(
                      message: p.erreur!,
                      onReessayer: () => context.read<RetraitProvider>().charger())
                else ...[
                  CarteHero(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Solde retirable',
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text(formatFcfa(solde),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const TitreSection('Opérateur'),
                  OngletsPilule(
                    libelles: _libelles,
                    index: _operateur,
                    onChanged: (i) => setState(() => _operateur = i),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: ChampTexte(
                      controller: _montant,
                      label: 'Montant à retirer',
                      icone: Icons.payments_outlined,
                      suffixe: 'FCFA',
                      clavier: TextInputType.number,
                      formatteurs: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty || int.parse(v) <= 0) {
                          return 'Saisissez un montant';
                        }
                        if (int.parse(v) > solde) {
                          return 'Montant supérieur à votre solde';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (p.erreur != null) ...[
                    const SizedBox(height: 12),
                    MessageErreur(message: p.erreur!),
                  ],
                  if (r != null && r.retraits.isNotEmpty) ...[
                    const TitreSection('Retraits (simulés)'),
                    CarteNeo(
                      child: Column(
                        children: [
                          for (var i = 0; i < r.retraits.length; i++) ...[
                            if (i > 0) const Divider(height: 22),
                            Row(
                              children: [
                                IconeRonde(
                                    icone: Icons.south_west_rounded, taille: 38),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(nomMethode(r.retraits[i].operateur),
                                          style: Typo.corps.copyWith(
                                              fontWeight: FontWeight.w600)),
                                      if (r.retraits[i].creeLe != null)
                                        Text(formatDateHeure(r.retraits[i].creeLe!),
                                            style: Typo.petit),
                                    ],
                                  ),
                                ),
                                Text(formatFcfa(r.retraits[i].montantFcfa),
                                    style: Typo.corps),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
    );
  }
}
