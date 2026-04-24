import 'package:flutter/material.dart';
import '../core/models/product_model.dart';

/// Singleton qui gère les produits favoris.
/// Utilise ValueNotifier pour notifier les widgets qui l'écoutent
/// sans avoir besoin d'un package de gestion d'état externe.
class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  final ValueNotifier<List<ProductModel>> favorites =
      ValueNotifier<List<ProductModel>>([]);

  bool isFavorite(String productId) =>
      favorites.value.any((p) => p.id == productId);

  void toggle(ProductModel product) {
    final current = List<ProductModel>.from(favorites.value);
    if (isFavorite(product.id)) {
      current.removeWhere((p) => p.id == product.id);
    } else {
      current.add(product);
    }
    favorites.value = current;
  }
}
