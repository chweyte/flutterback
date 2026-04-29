class ProductModel {
  final String id;
  final String name;
  final String price;
  final int priceValue;
  final bool isDark;
  final String? imageUrl;
  final int? categoryId;
  final List<String>? sizes;
  final String shopId;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.priceValue,
    this.isDark = false,
    this.imageUrl,
    this.categoryId,
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
      categoryId: map['category_id'],
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
      'category_id': categoryId,
      'sizes': sizes,
      'shop_id': shopId,
    };
  }
}
