import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/commerce/product_model.dart';

class ProductService extends ChangeNotifier {
  ProductService._();
  static final ProductService instance = ProductService._();
  bool _isInit = false;

  List<ProductModel> _products = [];
  bool isLoading = true;

  List<ProductModel> get all => _products;

  void initialize() {
    if (_isInit) return;
    _isInit = true;
    FirebaseFirestore.instance.collection('products').snapshots().listen((
      snapshot,
    ) {
      _products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> add(ProductModel product) async {
    await FirebaseFirestore.instance.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await FirebaseFirestore.instance.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).delete();
  }

  List<ProductModel> byShop(String shopId) =>
      _products.where((p) => p.shopId == shopId).toList();

  List<ProductModel> byCategory(String categoryId) =>
      _products.where((p) => p.category == categoryId).toList();
}
