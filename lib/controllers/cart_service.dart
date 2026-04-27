import 'package:flutter/material.dart';
import '../models/commerce/product_model.dart';

class CartItem {
  final ProductModel product;
  final String? size;
  int quantity;

  CartItem({required this.product, this.size, this.quantity = 1});
}

class CartService {
  CartService._();
  static final CartService instance = CartService._();

  final ValueNotifier<List<CartItem>> items = ValueNotifier([]);

  int get totalCount =>
      items.value.fold(0, (s, e) => s + e.quantity);

  int get totalPrice =>
      items.value.fold(0, (s, e) => s + e.product.priceValue * e.quantity);

  void add(ProductModel product, {String? size}) {
    final current = List<CartItem>.from(items.value);
    final idx = current.indexWhere(
        (i) => i.product.id == product.id && i.size == size);
    if (idx >= 0) {
      current[idx].quantity++;
    } else {
      current.add(CartItem(product: product, size: size));
    }
    items.value = current;
  }

  void remove(CartItem item) {
    final current = List<CartItem>.from(items.value);
    current.remove(item);
    items.value = current;
  }

  void increment(CartItem item) {
    final current = List<CartItem>.from(items.value);
    final idx = current.indexOf(item);
    if (idx >= 0) current[idx].quantity++;
    items.value = current;
  }

  void decrement(CartItem item) {
    final current = List<CartItem>.from(items.value);
    final idx = current.indexOf(item);
    if (idx >= 0) {
      if (current[idx].quantity > 1) {
        current[idx].quantity--;
      } else {
        current.removeAt(idx);
      }
    }
    items.value = current;
  }
}
