import '../core/formatters.dart';
import 'ligne_vente.dart';
import 'paiement.dart';

class Vente {
  final int id;
  final int totalFcfa;
  final String statut; // en_attente | payee | annulee
  final DateTime? creeLe;
  final List<LigneVente> lignes;
  final List<Paiement> paiements;

  const Vente({
    required this.id,
    required this.totalFcfa,
    required this.statut,
    this.creeLe,
    this.lignes = const [],
    this.paiements = const [],
  });

  bool get estPayee => statut == 'payee';
  bool get estEnAttente => statut == 'en_attente';
  bool get estAnnulee => statut == 'annulee';

  Paiement? get paiementPaye {
    for (final p in paiements) {
      if (p.estPaye) return p;
    }
    return null;
  }

  /// Moyen de paiement à afficher pour la vente.
  String get methode {
    final p = paiementPaye ?? (paiements.isNotEmpty ? paiements.last : null);
    return p?.methode ?? '';
  }

  String get titre {
    if (lignes.isEmpty) return 'Vente n°$id';
    final noms = lignes.map((l) => l.nomProduit).toList();
    return noms.length <= 2
        ? noms.join(', ')
        : '${noms.take(2).join(', ')} +${noms.length - 2}';
  }

  factory Vente.fromJson(Map<String, dynamic> j) => Vente(
        id: versInt(j['id']),
        totalFcfa: versInt(j['total_fcfa']),
        statut: j['statut']?.toString() ?? 'en_attente',
        creeLe: versDate(j['cree_le']),
        lignes: versListe(j['lignes']).map(LigneVente.fromJson).toList(),
        paiements: versListe(j['paiements']).map(Paiement.fromJson).toList(),
      );
}

class PointSerie {
  final DateTime? date;
  final int totalFcfa;
  const PointSerie({this.date, required this.totalFcfa});

  factory PointSerie.fromJson(Map<String, dynamic> j) =>
      PointSerie(date: versDate(j['date']), totalFcfa: versInt(j['total_fcfa']));
}

class TotalMethode {
  final String methode;
  final int totalFcfa;
  final int? totalSats;
  const TotalMethode(
      {required this.methode, required this.totalFcfa, this.totalSats});

  factory TotalMethode.fromJson(Map<String, dynamic> j) => TotalMethode(
        methode: j['methode']?.toString() ?? '',
        totalFcfa: versInt(j['total_fcfa']),
        totalSats: versIntOuNul(j['total_sats']),
      );
}

/// Résumé des ventes sur une période (7 jours, 30 jours, 3 mois).
class ResumePeriode {
  final int totalFcfa;
  final double? variationPct;
  final List<PointSerie> serie;
  final List<TotalMethode> parMethode;
  final List<Vente> ventes;

  const ResumePeriode({
    required this.totalFcfa,
    this.variationPct,
    this.serie = const [],
    this.parMethode = const [],
    this.ventes = const [],
  });

  factory ResumePeriode.fromJson(Map<String, dynamic> j) => ResumePeriode(
        totalFcfa: versInt(j['total_fcfa']),
        variationPct: versDoubleOuNul(j['variation_pct']),
        serie: versListe(j['serie']).map(PointSerie.fromJson).toList(),
        parMethode:
            versListe(j['par_methode']).map(TotalMethode.fromJson).toList(),
        ventes: versListe(j['ventes']).map(Vente.fromJson).toList(),
      );
}
