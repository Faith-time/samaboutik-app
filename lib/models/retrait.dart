import '../core/formatters.dart';

class Retrait {
  final int id;
  final int montantFcfa;
  final String operateur;
  final DateTime? creeLe;

  const Retrait({
    required this.id,
    required this.montantFcfa,
    required this.operateur,
    this.creeLe,
  });

  factory Retrait.fromJson(Map<String, dynamic> j) => Retrait(
        id: versInt(j['id']),
        montantFcfa: versInt(j['montant_fcfa']),
        operateur: j['operateur']?.toString() ?? '',
        creeLe: versDate(j['cree_le']),
      );
}

class ResumeRetraits {
  final int soldeFcfa;
  final List<Retrait> retraits;
  const ResumeRetraits({required this.soldeFcfa, this.retraits = const []});

  factory ResumeRetraits.fromJson(Map<String, dynamic> j) => ResumeRetraits(
        soldeFcfa: versInt(j['solde_fcfa']),
        retraits: versListe(j['retraits']).map(Retrait.fromJson).toList(),
      );
}
