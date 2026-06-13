import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/commerce/shop_model.dart';

class ShopService extends ChangeNotifier {
  ShopService._();
  static final ShopService instance = ShopService._();
  bool _isInit = false;

  List<ShopModel> _shops = [];
  bool isLoading = true;

  List<ShopModel> get all => _shops;

  void initialize() {
    if (_isInit) return;
    _isInit = true;
    
    refresh();

    Supabase.instance.client
        .from('shops')
        .stream(primaryKey: ['id'])
        .listen((data) {
      _shops = data.map((map) => ShopModel.fromMap(map, map['id'].toString())).toList();
      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print('=== SHOPS STREAM ERROR === : $e');
    });
  }

  Future<void> refresh() async {
    try {
      final data = await Supabase.instance.client.from('shops').select();
      _shops = data.map((map) => ShopModel.fromMap(map, map['id'].toString())).toList();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('=== ERROR REFRESHING SHOPS === : $e');
    }
  }

  Future<void> addShop(ShopModel shop) async {
    await Supabase.instance.client.from('shops').insert(shop.toMap());
  }

  Future<void> updateShop(ShopModel shop) async {
    await Supabase.instance.client
        .from('shops')
        .update(shop.toMap())
        .eq('id', shop.id);
  }
}
