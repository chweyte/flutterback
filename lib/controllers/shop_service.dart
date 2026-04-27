import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    FirebaseFirestore.instance.collection('shops').snapshots().listen((
      snapshot,
    ) {
      _shops = snapshot.docs
          .map((doc) => ShopModel.fromMap(doc.data(), doc.id))
          .toList();
      isLoading = false;
      notifyListeners();
    });
  }
}
