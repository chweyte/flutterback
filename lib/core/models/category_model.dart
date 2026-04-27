import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String labelKey;
  final IconData icon;
  final String? imageUrl;    // URL rÃ©seau
  final String? imageAsset;  // fichier local dans assets/

  const CategoryModel({
    required this.id,
    required this.labelKey,
    required this.icon,
    this.imageUrl,
    this.imageAsset,
  });
}

// Full category list for the marketplace.
// To add a new category: add a new CategoryModel entry here and add its
// translation key to each assets/translations/*.json file.
const List<CategoryModel> appCategories = [
  CategoryModel(id: 'new_in',       labelKey: 'categories_list.new_in',       icon: Icons.new_releases_outlined),
  CategoryModel(id: 'promotions',   labelKey: 'categories_list.promotions',   icon: Icons.local_offer_outlined),
  CategoryModel(id: 'perfumes',     labelKey: 'categories_list.perfumes',     icon: Icons.spa_outlined),
  CategoryModel(id: 'melhfa', labelKey: 'categories_list.melhfa', icon: Icons.dry_outlined,
    imageAsset: 'assets/melhfa.jpg'),
  CategoryModel(id: 'daraa',  labelKey: 'categories_list.daraa',  icon: Icons.accessibility_new_outlined,
    imageAsset: 'assets/daraa.jpg'),
  CategoryModel(id: 'bags',         labelKey: 'categories_list.bags',         icon: Icons.shopping_bag_outlined),
  CategoryModel(id: 'makeup',       labelKey: 'categories_list.makeup',       icon: Icons.face_retouching_natural),
  CategoryModel(id: 'skincare',     labelKey: 'categories_list.skincare',     icon: Icons.water_drop_outlined),
  CategoryModel(id: 'shoes',        labelKey: 'categories_list.shoes',        icon: Icons.directions_walk_outlined),
  CategoryModel(id: 'accessories',  labelKey: 'categories_list.accessories',  icon: Icons.watch_outlined),
  CategoryModel(id: 'clothing',     labelKey: 'categories_list.clothing',     icon: Icons.checkroom_outlined),
  CategoryModel(id: 'jewelry',      labelKey: 'categories_list.jewelry',      icon: Icons.diamond_outlined),
  CategoryModel(id: 'watches',      labelKey: 'categories_list.watches',      icon: Icons.watch_outlined),
  CategoryModel(id: 'phones',       labelKey: 'categories_list.phones',       icon: Icons.phone_android_outlined),
  CategoryModel(id: 'home_decor',   labelKey: 'categories_list.home_decor',   icon: Icons.home_outlined),
  CategoryModel(id: 'sports',       labelKey: 'categories_list.sports',       icon: Icons.sports_outlined),
];
