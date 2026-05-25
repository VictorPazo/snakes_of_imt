class SnakeModel {

  final int id;

  final String family;

  final String genus;

  final String specie;

  final String? description;

  final bool poisonous;

  final int dangerousness;

  final String venomType;

  final String? effectiveAntivenom;

  final String imageName;

  SnakeModel({

    required this.id,

    required this.family,

    required this.genus,

    required this.specie,

    this.description,

    required this.poisonous,

    required this.dangerousness,

    required this.venomType,

    this.effectiveAntivenom,

    required this.imageName,
  });

  factory SnakeModel.fromMap(
      Map<String, dynamic> map,
      ) {

    return SnakeModel(

      id: map['id'],

      family: map['family'],

      genus: map['genus'],

      specie: map['specie'],

      description: map['description'],

      poisonous: map['poisonous'],

      dangerousness: map['dangerousness'],

      venomType: map['venom_type'],

      effectiveAntivenom:
      map['effective_antivenom'],

      imageName: map['image_name'],
    );
  }
}