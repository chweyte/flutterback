class ShopModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? categoryTitle;
  final String? imageUrl; // URL réseau
  final String? imageAsset; // fichier local assets/
  final double rating;
  final int reviewCount;

  const ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.categoryTitle,
    this.imageUrl,
    this.imageAsset,
    this.rating = 4.5,
    this.reviewCount = 0,
  });

  factory ShopModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ShopModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      categoryTitle: map['categoryTitle'],
      imageUrl: map['imageUrl'],
      imageAsset: map['imageAsset'],
      rating: (map['rating'] ?? 4.5) * 1.0,
      reviewCount: map['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'categoryTitle': categoryTitle,
      'imageUrl': imageUrl,
      'imageAsset': imageAsset,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}
