import 'package:flutter/material.dart';

class CategoryModel {
  final int id;
  final String labelKey;
  final String? name;
  final IconData icon;
  final String? imageUrl; // URL rÃ©seau
  final String? imageAsset; // fichier local dans assets/

  const CategoryModel({
    required this.id,
    required this.labelKey,
    this.name,
    required this.icon,
    this.imageUrl,
    this.imageAsset,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CategoryModel(
      id: int.tryParse(documentId) ?? 0,
      labelKey: map['label_key'] ?? '',
      name: map['name'],
      icon: IconData(
        map['icon_code_point'] ?? 0xe000,
        fontFamily: map['icon_font_family'] ?? 'MaterialIcons',
      ),
      imageUrl: map['image_url'],
      imageAsset: map['image_asset'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label_key': labelKey,
      'name': name,
      'icon_code_point': icon.codePoint,
      'icon_font_family': icon.fontFamily,
      'image_url': imageUrl,
      'image_asset': imageAsset,
    };
  }
}
