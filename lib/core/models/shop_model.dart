class ShopModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? imageUrl;    // URL rÃ©seau
  final String? imageAsset;  // fichier local assets/
  final double rating;
  final int reviewCount;

  const ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl,
    this.imageAsset,
    this.rating = 4.5,
    this.reviewCount = 0,
  });
}

const List<ShopModel> allShops = [
  // â”€â”€ Mets tes photos : assets/bellah_dubai_cover.jpg  et  assets/bellah_dubai_logo.jpg
  ShopModel(
    id: 'shop_bellah',
    name: 'BELLAH DUBAI',
    description: 'Melhfa Ã©lÃ©gante â€” collection Dubai',
    category: 'Melhfa',
    imageAsset: 'assets/bellah_dubai_cover.jpg',
    rating: 4.9,
    reviewCount: 0,
  ),
  // â”€â”€ Mets tes photos : assets/boutique_homme_cover.jpg  et  assets/boutique_homme_logo.jpg
  ShopModel(
    id: 'shop_homme',
    name: 'DARRAH SHOP',
    description: 'Daraa premium â€” tenue traditionnelle',
    category: 'Daraa',
    imageAsset: 'assets/daraah_shop.jpg',
    rating: 4.8,
    reviewCount: 0,
  ),
  ShopModel(
    id: 'shop_2',
    name: 'Parfumerie Al Oud',
    description: 'Parfums orientaux et modernes',
    category: 'Parfums',
    imageUrl: 'https://images.unsplash.com/photo-1592945403407-9caf930c9b44?w=400&q=80',
    rating: 4.9,
    reviewCount: 210,
  ),
  ShopModel(
    id: 'shop_3',
    name: 'Bijouterie d\'Or',
    description: 'Bijoux et montres de luxe',
    category: 'Bijoux',
    imageUrl: 'https://images.unsplash.com/photo-1573408301185-9519f94ae24d?w=400&q=80',
    rating: 4.7,
    reviewCount: 89,
  ),
  ShopModel(
    id: 'shop_4',
    name: 'Mode & Style',
    description: 'VÃªtements, chaussures et sacs tendance',
    category: 'Mode',
    imageUrl: 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=400&q=80',
    rating: 4.6,
    reviewCount: 178,
  ),
  ShopModel(
    id: 'shop_5',
    name: 'Beauty Corner',
    description: 'Maquillage et soins de la peau',
    category: 'BeautÃ©',
    imageUrl: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&q=80',
    rating: 4.8,
    reviewCount: 305,
  ),
  ShopModel(
    id: 'shop_6',
    name: 'Maison & Sport',
    description: 'DÃ©coration, sport et accessoires',
    category: 'Divers',
    imageUrl: 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=400&q=80',
    rating: 4.4,
    reviewCount: 67,
  ),
];
