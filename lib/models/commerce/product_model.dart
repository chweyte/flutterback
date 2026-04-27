class ProductModel {
  final String id;
  final String name;
  final String price;
  final int priceValue;
  final bool isDark;
  final String? imageUrl;
  final String? imageAsset;
  final String category;
  final String shopId;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.priceValue,
    this.isDark = false,
    this.imageUrl,
    this.imageAsset,
    required this.category,
    required this.shopId,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      priceValue: map['priceValue'] ?? 0,
      isDark: map['isDark'] ?? false,
      imageUrl: map['imageUrl'],
      imageAsset: map['imageAsset'],
      category: map['category'] ?? '',
      shopId: map['shopId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'priceValue': priceValue,
      'isDark': isDark,
      'imageUrl': imageUrl,
      'imageAsset': imageAsset,
      'category': category,
      'shopId': shopId,
    };
  }
}


