class CardImage {
  const CardImage({required this.small, required this.normal});

  final String small;
  final String normal;

  static CardImage? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return CardImage(small: json['small'] as String, normal: json['normal'] as String);
  }
}

class Printing {
  const Printing({
    required this.id,
    required this.set,
    required this.product,
    required this.finish,
    required this.artist,
    required this.typeline,
    this.flavour,
    this.image,
  });

  final String id;
  final String set;
  final String product;
  final String finish;
  final String? artist;
  final String? typeline;
  final String? flavour;
  final CardImage? image;

  factory Printing.fromJson(Map<String, dynamic> json) => Printing(
        id: json['id'] as String,
        set: json['set'] as String,
        product: json['product'] as String,
        finish: json['finish'] as String,
        artist: json['artist'] as String?,
        typeline: json['typeline'] as String?,
        flavour: json['flavour'] as String?,
        image: CardImage.fromJson(json['image'] as Map<String, dynamic>?),
      );
}

class SorceryCard {
  SorceryCard({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.subtypes,
    required this.elements,
    required this.keywords,
    required this.cost,
    required this.attack,
    required this.defense,
    required this.life,
    required this.thresholds,
    required this.rules,
    required this.sets,
    required this.image,
    required this.printings,
  });

  final String id;
  final String name;
  final String type;
  final String? rarity;
  final List<String> subtypes;
  final List<String> elements;
  final List<String> keywords;
  final int? cost;
  final int? attack;
  final int? defense;
  final int? life;

  /// Threshold per element: air, earth, fire, water.
  final Map<String, int> thresholds;
  final String rules;
  final List<String> sets;
  final CardImage? image;
  final List<Printing> printings;

  /// Lower-cased text used by the search box.
  late final String searchText =
      '$name\n$rules\n${subtypes.join(' ')}\n${keywords.join(' ')}'.toLowerCase();

  factory SorceryCard.fromJson(Map<String, dynamic> json) => SorceryCard(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        rarity: json['rarity'] as String?,
        subtypes: List<String>.from(json['subtypes'] as List),
        elements: List<String>.from(json['elements'] as List),
        keywords: List<String>.from(json['keywords'] as List),
        cost: json['cost'] as int?,
        attack: json['attack'] as int?,
        defense: json['defense'] as int?,
        life: json['life'] as int?,
        thresholds: Map<String, int>.from(json['thresholds'] as Map),
        rules: json['rules'] as String,
        sets: List<String>.from(json['sets'] as List),
        image: CardImage.fromJson(json['image'] as Map<String, dynamic>?),
        printings: (json['printings'] as List)
            .map((p) => Printing.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}
