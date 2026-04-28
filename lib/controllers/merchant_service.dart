import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      final snapshot = await FirebaseFirestore.instance
          .collection('shops')
          .where('merchantId', isEqualTo: merchantId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        currentShop = ShopModel.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
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
