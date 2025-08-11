class ClosetData {

  static const List<String> categories = [
    "Tops",
    "Bottoms",
    "Shoes",
    "Hijabs",
    "Accessories"
  ];

  static const List<String> seasons = [
    "Spring",
    "Summer",
    "Autumn",
    "Winter",
    "All Season"
  ];

  static const List<String> styles = [
    "Casual",
    "Formal",
    "Both"
  ];

  static const Map<String, List<String>> fabricsByCategory = {
    "Tops": [
      "Cotton",
      "Linen",
      "Silk",
      "Polyester",
      "Wool",
      "Denim",
      "Rayon",
      "Jersey"
    ],
    "Bottoms": [
      "Cotton",
      "Linen",
      "Wool",
      "Denim",
      "Polyester",
      "Corduroy",
      "Khaki"
    ],
    "Shoes": [
      "Leather",
      "Suede",
      "Canvas",
      "Synthetic",
      "Rubber",
      "Mesh"
    ],
    "Hijabs": [
      "Chiffon",
      "Silk",
      "Cotton",
      "Viscose",
      "Jersey",
      "Linen"
    ],
    "Accessories": [
      "Metal",
      "Plastic",
      "Leather",
      "Wood",
      "Beads",
      "Fabric"
    ],
  };
}
