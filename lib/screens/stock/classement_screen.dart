import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/stock_outils.dart';
import '../../core/theme.dart';
import '../../models/stock.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/chargement.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import '../../widgets/message_erreur.dart';
import '../../widgets/onglets_pilule.dart';
import '../../widgets/stock_widgets.dart';
import '../produits/formulaire_produit_screen.dart';
import 'reapprovisionner_screen.dart';
import '../../widgets/image_produit.dart';

/// Classement de TOUS les produits : du plus vendu au moins vendu.
class ClassementScreen extends StatefulWidget {
  const ClassementScreen({super.key});

  @override
  State<ClassementScreen> createState() => _ClassementScreenState();
}

class _ClassementScreenState extends State<ClassementScreen> {
  static const _periodes = ['jour', 'semaine', 'mois', 'annee'];
  static const _libellesPeriodes = ['Jour', 'Semaine', 'Mois', 'Année'];
  static const _choixTri = <(String, String, IconData)>[
    ('quantite', 'Plus vendus', Icons.shopping_bag_outlined),
    ('benefice', 'Plus rentables', Icons.savings_outlined),
    ('ca', 'Plus de ventes', Icons.payments_outlined),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StockProvider>().chargerClassement();
    });
  }

  String _explication(String periode) {
    switch (periode) {
      case 'jour':
        return "Aujourd'hui";
      case 'semaine':
        return 'Ces 7 derniers jours';
      case 'mois':
        return 'Ces 30 derniers jours';
      default:
        return 'Cette dernière année';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<StockProvider>();
    final c = s.classement;
    final iP = _periodes.indexOf(s.periode).clamp(0, 3).toInt();

    Widget contenu;
    if (s.erreurClassement != null && c == null) {
      contenu = MessageErreur(
          message: s.erreurClassement!,
          onReessayer: () => context.read<StockProvider>().chargerClassement());
    } else if (c == null) {
      contenu = const SizedBox(height: 260, child: Chargement());
    } else if (c.lignes.isEmpty) {
      contenu = EtatVide(
        icone: Icons.leaderboard_outlined,
        titre: 'Aucun produit',
        texte: 'Ajoutez vos produits pour voir leur classement.',
        libelleAction: 'Ajouter un produit',
        onAction: () => aller(context, const FormulaireProduitScreen()),
      );
    } else {
      final vendus = c.lignes.where((l) => l.quantite > 0).toList();
      final sans = c.lignes.where((l) => l.quantite == 0).toList();
      final podium = vendus.take(3).toList();
      final autres = vendus.skip(3).toList();

      contenu = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResumeHero(c: c, texte: _explication(c.periode)),
          if (vendus.isEmpty) ...[
            const SizedBox(height: 24),
            const CarteNeo(
              padding: EdgeInsets.all(20),
              child: Text(
                'Aucune vente sur cette période. Choisissez une période plus longue pour voir votre classement.',
                style: TextStyle(fontSize: 15, height: 1.45),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            const TitreSection('Le podium'),
            for (final l in podium)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CartePodium(ligne: l, tri: s.tri),
              ),
            if (autres.isNotEmpty) ...[
              const TitreSection('Les autres produits'),
              for (final l in autres)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _CarteRang(ligne: l, tri: s.tri),
                ),
            ],
          ],
          if (sans.isNotEmpty) ...[
            const TitreSection('Aucune vente sur la période'),
            CarteNeo(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                children: [
                  for (var i = 0; i < sans.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _LigneSansVente(ligne: sans[i]),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    }

    return EcranNeo(
      titre: 'Classement des produits',
      retour: true,
      defiler: true,
      onRefresh: () => context.read<StockProvider>().chargerClassement(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OngletsPilule(
            libelles: _libellesPeriodes,
            index: iP,
            onChanged: (i) => context
                .read<StockProvider>()
                .chargerClassement(periode: _periodes[i]),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text('Classer les produits par :', style: Typo.doux),
          ),
          Row(
            children: [
              for (var i = 0; i < _choixTri.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _PuceTri(
                    libelle: _choixTri[i].$2,
                    icone: _choixTri[i].$3,
                    choisi: s.tri == _choixTri[i].$1,
                    onTap: () => context
                        .read<StockProvider>()
                        .chargerClassement(tri: _choixTri[i].$1),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 22),
          contenu,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- composants

class _PuceTri extends StatelessWidget {
  final String libelle;
  final IconData icone;
  final bool choisi;
  final VoidCallback onTap;
  const _PuceTri({
    required this.libelle,
    required this.icone,
    required this.choisi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final contenu = Column(
      children: [
        Icon(icone, size: 26, color: choisi ? Colors.white : Couleurs.bleu),
        const SizedBox(height: 6),
        Text(
          libelle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: choisi ? Colors.white : Couleurs.texte,
          ),
        ),
      ],
    );
    const marge = EdgeInsets.symmetric(vertical: 14, horizontal: 6);
    return choisi
        ? CarteNeo(
        couleur: Couleurs.bleu,
        ombres: const [],
        rayon: 18,
        padding: marge,
        onTap: onTap,
        child: contenu)
        : CarteNeo(rayon: 18, padding: marge, onTap: onTap, child: contenu);
  }
}

class _ResumeHero extends StatelessWidget {
  final Classement c;
  final String texte;
  const _ResumeHero({required this.c, required this.texte});

  @override
  Widget build(BuildContext context) => CarteHero(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texte,
            style: const TextStyle(color: Colors.white70, fontSize: 15)),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TotalHero(
                  flex: 5,
                  titre: 'Ventes',
                  valeur: formatFcfa(c.totalCaFcfa)),
              const _SeparateurHero(),
              _TotalHero(
                  flex: 5,
                  titre: 'Bénéfice',
                  valeur: formatFcfa(c.totalBeneficeFcfa)),
              const _SeparateurHero(),
              _TotalHero(
                  flex: 4,
                  titre: 'Articles vendus',
                  valeur: '${c.totalQuantite}'),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Fin séparateur vertical entre deux totaux, avec de l'air de chaque côté.
class _SeparateurHero extends StatelessWidget {
  const _SeparateurHero();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    color: Colors.white24,
  );
}

class _TotalHero extends StatelessWidget {
  final String titre;
  final String valeur;
  final int flex;
  const _TotalHero({
    required this.titre,
    required this.valeur,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(valeur,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(titre,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      ],
    ),
  );
}

Color? _couleurMedaille(int rang) {
  if (rang == 1) return const Color(0xFFF5B301);
  if (rang == 2) return const Color(0xFF9AA5B8);
  if (rang == 3) return const Color(0xFFCD7F32);
  return null;
}

class _Rang extends StatelessWidget {
  final int rang;
  final double taille;
  const _Rang(this.rang, {this.taille = 40});

  @override
  Widget build(BuildContext context) {
    final m = _couleurMedaille(rang);
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(color: m ?? Couleurs.champ, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$rang',
          style: TextStyle(
            color: m != null ? Colors.white : Couleurs.texteDoux,
            fontSize: taille * .42,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

String _valeurTri(LigneClassement l, String tri) {
  if (tri == 'ca') return formatFcfa(l.caFcfa);
  if (tri == 'benefice') {
    return l.beneficeFcfa == null ? '—' : formatFcfa(l.beneficeFcfa!);
  }
  return '${l.quantite} vendu${l.quantite > 1 ? 's' : ''}';
}

class _Chiffre extends StatelessWidget {
  final String titre;
  final String valeur;
  final bool fort;
  const _Chiffre({required this.titre, required this.valeur, this.fort = false});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            valeur,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: fort ? Couleurs.bleu : Couleurs.texte,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(titre, style: Typo.petit.copyWith(fontSize: 12.5)),
      ],
    ),
  );
}

class _BlocStock extends StatelessWidget {
  final LigneClassement l;
  const _BlocStock(this.l);

  @override
  Widget build(BuildContext context) {
    final couleur = couleurStatutStock(l.statutStock);
    final suivi = l.suivreStock;
    final lots = (l.lotsRestants != null && l.stockActuel > 0)
        ? ' (${texteLots(l.lotsRestants!)})'
        : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 26),
        Row(
          children: [
            Icon(Icons.inventory_2_outlined, size: 20, color: couleur),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                suivi ? 'Il reste ${texteUnites(l.stockActuel)}$lots' : 'Stock non suivi',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: Couleurs.texte),
              ),
            ),
            PastilleStock(l.statutStock),
          ],
        ),
        if (suivi && l.niveauStock != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: l.niveauStock!.clamp(0.0, 1.0),
              minHeight: 10,
              color: couleur,
              backgroundColor: Couleurs.champ,
            ),
          ),
        ],
      ],
    );
  }
}

class _CartePodium extends StatelessWidget {
  final LigneClassement ligne;
  final String tri;
  const _CartePodium({required this.ligne, required this.tri});

  @override
  Widget build(BuildContext context) {
    final l = ligne;
    final fond = l.rang == 1
        ? const Color(0xFFFFF8E1)
        : l.rang == 2
        ? const Color(0xFFF1F4F9)
        : const Color(0xFFFFF1E6);

    return CarteNeo(
      couleur: fond,
      rayon: 24,
      padding: const EdgeInsets.all(18),
      onTap: () => aller(context, ReapprovisionnerScreen(produitId: l.produitId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Rang(l.rang, taille: 50),
              const SizedBox(width: 12),
              _VignetteLigne(l, taille: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Chiffre(titre: 'Vendus', valeur: '${l.quantite}', fort: tri == 'quantite'),
              _Chiffre(titre: 'Ventes', valeur: formatFcfa(l.caFcfa), fort: tri == 'ca'),
              _Chiffre(
                titre: 'Bénéfice',
                valeur: l.beneficeFcfa == null ? '—' : formatFcfa(l.beneficeFcfa!),
                fort: tri == 'benefice',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (l.partPct / 100).clamp(0.0, 1.0),
                    minHeight: 10,
                    color: Couleurs.bleu,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${l.partPct.toStringAsFixed(0)} % des ventes',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          _BlocStock(l),
        ],
      ),
    );
  }
}

class _CarteRang extends StatelessWidget {
  final LigneClassement ligne;
  final String tri;
  const _CarteRang({required this.ligne, required this.tri});

  @override
  Widget build(BuildContext context) {
    final l = ligne;
    return CarteNeo(
      rayon: 22,
      padding: const EdgeInsets.all(16),
      onTap: () => aller(context, ReapprovisionnerScreen(produitId: l.produitId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Rang(l.rang),
              const SizedBox(width: 10),
              _VignetteLigne(l, taille: 44),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              Text(_valeurTri(l, tri),
                  style: const TextStyle(
                      fontSize: 15.5, fontWeight: FontWeight.w800, color: Couleurs.bleu)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Chiffre(titre: 'Vendus', valeur: '${l.quantite}'),
              _Chiffre(titre: 'Ventes', valeur: formatFcfa(l.caFcfa)),
              _Chiffre(
                titre: 'Bénéfice',
                valeur: l.beneficeFcfa == null ? '—' : formatFcfa(l.beneficeFcfa!),
              ),
            ],
          ),
          _BlocStock(l),
        ],
      ),
    );
  }
}

class _LigneSansVente extends StatelessWidget {
  final LigneClassement ligne;
  const _LigneSansVente({required this.ligne});

  @override
  Widget build(BuildContext context) {
    final l = ligne;
    return InkWell(
      onTap: () => aller(context, ReapprovisionnerScreen(produitId: l.produitId)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            VignetteProduit(
              produitId: l.produitId,
              nom: l.nom,
              taille: 40,
              repli: const Icon(Icons.hourglass_empty_rounded,
                  size: 22, color: Couleurs.texteDoux),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l.nom,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
            ),
            PastilleStock(l.statutStock),
          ],
        ),
      ),
    );
  }
}
/// Photo du produit d'une ligne du classement (icône si pas de photo).
class _VignetteLigne extends StatelessWidget {
  final LigneClassement ligne;
  final double taille;
  const _VignetteLigne(this.ligne, {required this.taille});

  @override
  Widget build(BuildContext context) => VignetteProduit(
        produitId: ligne.produitId,
        nom: ligne.nom,
        taille: taille,
        repli: IconeRonde(
          icone: Icons.inventory_2_outlined,
          taille: taille,
        ),
      );
}
