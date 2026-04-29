class ProductModel {
  final String id;
  final String name;
  final String price;
  final int priceValue;
  final bool isDark;
  final String? imageUrl;
  final String? imageAsset;
  final String category;
  final String? categoryTitle;
  final List<String>? sizes;
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
    this.categoryTitle,
    this.sizes,
    required this.shopId,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      priceValue: map['price_value'] ?? 0,
      isDark: map['is_dark'] ?? false,
      imageUrl: map['image_url'],
      imageAsset: map['image_asset'],
      category: map['category'] ?? '',
      categoryTitle: map['category_title'],
      sizes: map['sizes'] != null ? List<String>.from(map['sizes']) : null,
      shopId: map['shop_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'price_value': priceValue,
      'is_dark': isDark,
      'image_url': imageUrl,
      'image_asset': imageAsset,
      'category': category,
      'category_title': categoryTitle,
      'sizes': sizes,
      'shop_id': shopId,
    };
  }
}
