import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    
    Supabase.instance.client
        .from('categories')
        .stream(primaryKey: ['id'])
        .listen((data) {
      _categories = data.map((map) => CategoryModel.fromMap(map, map['id'].toString())).toList();
      isLoading = false;
      notifyListeners();
    });
  }
}