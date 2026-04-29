import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/commerce/shop_model.dart';

class MerchantService extends ChangeNotifier {
  MerchantService._();
  static final MerchantService instance = MerchantService._();

  ShopModel? currentShop;
  bool isLoadingShop = false;

  bool get hasShop => currentShop != null;

  void setShop(ShopModel shop) {
    currentShop = shop;
    notifyListeners();
  }

  void clear() {
    currentShop = null;
    notifyListeners();
  }

  Future<void> loadMerchantShop(String merchantId) async {
    isLoadingShop = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('shops')
          .select()
          .eq('merchant_id', merchantId)
          .maybeSingle();

      if (response != null) {
        currentShop = ShopModel.fromMap(
          response,
          response['id'].toString(),
        );
      } else {
        currentShop = null;
      }
    } catch (e) {
      print('Erreur lors du chargement de la boutique: $e');
      currentShop = null;
    } finally {
      isLoadingShop = false;
      notifyListeners();
    }
  }
}
