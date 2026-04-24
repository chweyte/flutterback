import 'package:flutter/foundation.dart';
import '../core/models/product_model.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  final ValueNotifier<List<ProductModel>> products =
      ValueNotifier(List.from(allProducts));

  List<ProductModel> get all => products.value;

  void add(ProductModel product) {
    products.value = [...products.value, product];
  }

  List<ProductModel> byShop(String shopId) =>
      products.value.where((p) => p.shopId == shopId).toList();

  List<ProductModel> byCategory(String categoryId) =>
      products.value.where((p) => p.category == categoryId).toList();
}
