class Boutique {
  final int id;
  final String nom;

  Boutique({required this.id, required this.nom});

  factory Boutique.fromJson(Map<String, dynamic> json) =>
      Boutique(id: json['id'], nom: json['nom']);
}
