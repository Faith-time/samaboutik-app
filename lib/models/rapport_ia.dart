import '../core/formatters.dart';

class RapportIa {
  final String resume;
  final List<String> conseils;
  final DateTime? creeLe;

  const RapportIa({required this.resume, this.conseils = const [], this.creeLe});

  factory RapportIa.fromJson(Map<String, dynamic> j) => RapportIa(
        resume: j['resume']?.toString() ?? '',
        conseils: j['conseils'] is List
            ? (j['conseils'] as List).map((e) => e.toString()).toList()
            : <String>[],
        creeLe: versDate(j['cree_le']),
      );
}
