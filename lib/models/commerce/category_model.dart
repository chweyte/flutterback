import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String labelKey;
  final IconData icon;
  final String? imageUrl;    // URL rÃƒÂ©seau
  final String? imageAsset;  // fichier local dans assets/

  const CategoryModel({
    required this.id,
    required this.labelKey,
    required this.icon,
    this.imageUrl,
    this.imageAsset,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CategoryModel(
      id: documentId,
      labelKey: map['labelKey'] ?? '',
      icon: IconData(
        map['iconCodePoint'] ?? 0xe000, 
        fontFamily: map['iconFontFamily'] ?? 'MaterialIcons'
      ),
      imageUrl: map['imageUrl'],
      imageAsset: map['imageAsset'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'labelKey': labelKey,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'imageUrl': imageUrl,
      'imageAsset': imageAsset,
    };
  }
}

