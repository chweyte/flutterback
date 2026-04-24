import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/shop_model.dart';
import '../../core/theme/app_colors.dart';
import '../../services/merchant_service.dart';
import '../../services/route_transitions.dart';
import 'merchant_home.dart';

class ShopSetupScreen extends StatefulWidget {
  const ShopSetupScreen({super.key});

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Entrez le nom de votre boutique');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final db = FirebaseFirestore.instance;

      // Chercher dans Firestore si la boutique existe déjà
      final q = await db.collection('shops')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      ShopModel shop;

      if (q.docs.isNotEmpty) {
        // Boutique existante — synchroniser
        final data = q.docs.first.data();
        shop = ShopModel(
          id: q.docs.first.id,
          name: data['name'] ?? name,
          description: data['description'] ?? '',
          category: data['category'] ?? 'Général',
          rating: (data['rating'] ?? 4.5).toDouble(),
          reviewCount: data['reviewCount'] ?? 0,
        );
        // Lier le compte au shop
        await db.collection('users').doc(uid).update({'shopId': shop.id});
      } else {
        // Nouvelle boutique — créer dans Firestore
        final ref = await db.collection('shops').add({
          'name': name,
          'description': '',
          'category': 'Général',
          'ownerId': uid,
          'rating': 4.5,
          'reviewCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
        shop = ShopModel(
          id: ref.id,
          name: name,
          description: '',
          category: 'Général',
        );
        await db.collection('users').doc(uid).update({'shopId': ref.id});
      }

      MerchantService.instance.setShop(shop);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          SlidePageRoute(page: const MerchantHome()),
          (r) => false,
        );
      }
    } catch (e) {
      setState(() => _error = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              // Icône
              Container(
                width: 64.r,
                height: 64.r,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.store_rounded,
                    color: Colors.white, size: 30.r),
              ),
              SizedBox(height: 24.h),
              Text(
                'Votre boutique',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Entrez le nom exact de votre boutique.\nSi elle existe déjà, vos produits seront synchronisés.',
                style: TextStyle(
                    fontSize: 14.sp, color: AppColors.textSecondary,
                    height: 1.5),
              ),
              SizedBox(height: 32.h),

              // Champ nom
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Ex: BELLAH DUBAI',
                    hintStyle: TextStyle(
                        color: AppColors.textLight, fontSize: 14.sp),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 14.h),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.store_outlined,
                        color: AppColors.textSecondary, size: 20.r),
                  ),
                ),
              ),

              if (_error != null) ...[
                SizedBox(height: 8.h),
                Text(_error!,
                    style: TextStyle(
                        color: AppColors.accent, fontSize: 12.sp)),
              ],

              const Spacer(),

              // Bouton
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
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Continuer',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
