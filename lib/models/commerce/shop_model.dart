class ShopModel {
  final String id;
  final String name;
  final String description;
  final List<int> categoryIds;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String? merchantId;

  const ShopModel({
    required this.id,
    required this.name,
    required this.description,
    this.categoryIds = const [],
    this.imageUrl,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.merchantId,
  });

  factory ShopModel.fromMap(
    Map<String, dynamic> map,
    String documentId, {
    List<int>? categories,
  }) {
    return ShopModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      categoryIds: categories ?? [],
      imageUrl: map['image_url'],
      rating: (map['rating'] ?? 4.5) * 1.0,
      reviewCount: map['review_count'] ?? 0,
      merchantId: map['merchant_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'merchant_id': merchantId,
    };
  }
}
