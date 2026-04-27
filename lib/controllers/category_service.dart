import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/commerce/category_model.dart';

class CategoryService extends ChangeNotifier {
  CategoryService._();
  static final CategoryService instance = CategoryService._();
  bool _isInit = false;

  List<CategoryModel> _categories = [];
  bool isLoading = true;

  List<CategoryModel> get all => _categories;

  void initialize() {
    if (_isInit) return;
    _isInit = true;
    FirebaseFirestore.instance.collection('categories').snapshots().listen((snapshot) {
      _categories = snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
      isLoading = false;
      notifyListeners();
    });
  }
}