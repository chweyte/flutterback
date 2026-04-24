import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/category_model.dart';
import '../../core/models/product_model.dart';
import '../../core/theme/app_colors.dart';
import '../../services/merchant_service.dart';
import '../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  String? _selectedCategory;
  final Set<String> _selectedSizes = {};
  File? _imageFile;
  bool _loading = false;

  // Tailles disponibles selon catégorie
  List<String>? get _availableSizes {
    switch (_selectedCategory) {
      case 'melhfa': return ['1m', '2m'];
      case 'daraa':  return ['3m','4m','5m','6m','7m','8m','9m','10m','11m','12m'];
      case 'shoes':  return ['36','37','38','39','40','41','42','43','44'];
      case 'clothing': return ['XS','S','M','L','XL','XXL','XXXL','4XL'];
      default: return null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submit() async {
    final name  = _nameCtrl.text.trim();
    final price = _priceCtrl.text.trim();

    if (name.isEmpty || price.isEmpty || _selectedCategory == null) {
      _snack('Remplissez tous les champs obligatoires');
      return;
    }
    if (_availableSizes != null && _selectedSizes.isEmpty) {
      _snack('Choisissez au moins une taille');
      return;
    }
    if (_imageFile == null) {
      _snack('Ajoutez une photo du produit');
      return;
    }

    setState(() => _loading = true);

    final shop = MerchantService.instance.currentShop;
    final priceInt = int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final id = 'm_${DateTime.now().millisecondsSinceEpoch}';

    final product = ProductModel(
      id: id,
      name: name,
      price: '$price MRU',
      priceValue: priceInt,
      imageAsset: _imageFile!.path,
      category: _selectedCategory!,
      shopId: shop?.id ?? 'unknown',
    );

    ProductService.instance.add(product);

    setState(() => _loading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name ajouté à ${shop?.name ?? "votre boutique"}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _availableSizes;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38.r, height: 38.r,
                      decoration: const BoxDecoration(
                          color: AppColors.surface, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16.r, color: AppColors.textPrimary),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text('Ajouter un produit',
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Photo ──────────────────────────────────────
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18.r),
                                child: Image.file(_imageFile!,
                                    fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 40.r,
                                      color: AppColors.textSecondary),
                                  SizedBox(height: 8.h),
                                  Text('Appuyez pour ajouter une photo',
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Nom ─────────────────────────────────────────
                    _Label('Nom du produit'),
                    SizedBox(height: 6.h),
                    _Field(
                        controller: _nameCtrl,
                        hint: 'Ex: Kati Premium'),
                    SizedBox(height: 16.h),

                    // ── Prix ─────────────────────────────────────────
                    _Label('Prix (MRU)'),
                    SizedBox(height: 6.h),
                    _Field(
                      controller: _priceCtrl,
                      hint: 'Ex: 14500',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.h),

                    // ── Catégorie ────────────────────────────────────
                    _Label('Catégorie'),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: Text('Choisir une catégorie',
                            style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 13.sp)),
                        items: appCategories
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Row(
                                    children: [
                                      Icon(c.icon,
                                          size: 16.r,
                                          color: AppColors.textSecondary),
                                      SizedBox(width: 8.w),
                                      Text(c.labelKey
                                          .replaceFirst(
                                              'categories_list.', '')
                                          .toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 13.sp)),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedCategory = v;
                          _selectedSizes.clear();
                        }),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── Tailles (selon catégorie) ────────────────────
                    if (sizes != null) ...[
                      _Label('Tailles disponibles'),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: sizes.map((s) {
                          final selected = _selectedSizes.contains(s);
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (selected) {
                                _selectedSizes.remove(s);
                              } else {
                                _selectedSizes.add(s);
                              }
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: selected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${_selectedSizes.length} taille(s) sélectionnée(s)',
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    SizedBox(height: 16.h),

                    // ── Bouton ───────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline_rounded,
                                      size: 18.r),
                                  SizedBox(width: 8.w),
                                  Text('Publier le produit',
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  const _Field(
      {required this.controller,
      required this.hint,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: AppColors.textLight, fontSize: 13.sp),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
