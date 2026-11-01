import 'boutique.dart';

class Utilisateur {
  final int id;
  final String nom;
  final String telephone;
  final Boutique? boutique;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.telephone,
    this.boutique,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) => Utilisateur(
        id: json['id'],
        nom: json['nom'],
        telephone: json['telephone'],
        boutique: json['boutique'] != null
            ? Boutique.fromJson(json['boutique'])
            : null,
      );
}
