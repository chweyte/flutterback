import '../core/models/shop_model.dart';

class MerchantService {
  MerchantService._();
  static final MerchantService instance = MerchantService._();

  ShopModel? currentShop;

  bool get hasShop => currentShop != null;

  void setShop(ShopModel shop) {
    currentShop = shop;
  }

  void clear() {
    currentShop = null;
  }
}
