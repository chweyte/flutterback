import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    
    refresh();

    Supabase.instance.client
        .from('products')
        .stream(primaryKey: ['id'])
        .listen((data) {
      _products = data.map((map) => ProductModel.fromMap(map, map['id'].toString())).toList();
      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print('=== PRODUCTS STREAM ERROR === : $e');
    });
  }

  Future<void> refresh() async {
    try {
      final data = await Supabase.instance.client.from('products').select();
      _products = data.map((map) => ProductModel.fromMap(map, map['id'].toString())).toList();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('=== ERROR REFRESHING PRODUCTS === : $e');
    }
  }

  Future<void> add(ProductModel product) async {
    await Supabase.instance.client.from('products').insert(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await Supabase.instance.client
        .from('products')
        .update(product.toMap())
        .eq('id', product.id);
  }

  Future<void> deleteProduct(String productId) async {
    await Supabase.instance.client
        .from('products')
        .delete()
        .eq('id', productId);
  }

  List<ProductModel> byShop(String shopId) =>
      _products.where((p) => p.shopId == shopId).toList();

  List<ProductModel> byCategory(int categoryId) =>
      _products.where((p) => p.categoryId == categoryId).toList();
}
