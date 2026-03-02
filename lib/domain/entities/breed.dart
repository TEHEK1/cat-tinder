class Breed {
  final String id;
  final String name;
  final String description;
  final String temperament;
  final String origin;
  final String lifeSpan;
  final Map<String, String> weight;
  final int? affectionLevel;
  final int? energyLevel;
  final int? intelligence;
  final int? childFriendly;

  Breed({
    required this.id,
    required this.name,
    required this.description,
    required this.temperament,
    required this.origin,
    required this.lifeSpan,
    required this.weight,
    this.affectionLevel,
    this.energyLevel,
    this.intelligence,
    this.childFriendly,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      temperament: json['temperament'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      lifeSpan: json['life_span'] as String? ?? '',
      weight: {
        'imperial': json['weight']?['imperial'] as String? ?? '',
        'metric': json['weight']?['metric'] as String? ?? '',
      },
      affectionLevel: json['affection_level'] as int?,
      energyLevel: json['energy_level'] as int?,
      intelligence: json['intelligence'] as int?,
      childFriendly: json['child_friendly'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'temperament': temperament,
      'origin': origin,
      'life_span': lifeSpan,
      'weight': weight,
      'affection_level': affectionLevel,
      'energy_level': energyLevel,
      'intelligence': intelligence,
      'child_friendly': childFriendly,
    };
  }
}
