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
  final String? merchantId;

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
    this.merchantId,
  });

  factory ShopModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ShopModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      categoryTitle: map['category_title'],
      imageUrl: map['image_url'],
      imageAsset: map['image_asset'],
      rating: (map['rating'] ?? 4.5) * 1.0,
      reviewCount: map['review_count'] ?? 0,
      merchantId: map['merchant_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'category_title': categoryTitle,
      'image_url': imageUrl,
      'image_asset': imageAsset,
      'rating': rating,
      'review_count': reviewCount,
      'merchant_id': merchantId,
    };
  }
}
