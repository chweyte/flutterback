import '../../controllers/shop_service.dart';
import '../../controllers/product_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/commerce/shop_model.dart';
import '../../models/commerce/product_model.dart';
import '../../controllers/category_service.dart';
import '../../models/commerce/category_model.dart';
import '../../core/theme/app_colors.dart';
import '../../views/widgets/product_card_widget.dart';

class ShopDetailScreen extends StatelessWidget {
  final ShopModel shop;
  const ShopDetailScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final products = context
        .watch<ProductService>()
        .all
        .where((p) => p.shopId == shop.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Image de couverture
                SizedBox(
                  height: 200.h,
                  width: double.infinity,
                  child: _ShopCover(shop: shop),
                ),
                // -- Dégradé bas --
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80.h,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFFF2F2F7), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                // Bouton retour
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38.r,
                        height: 38.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16.r,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    shop.description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      // Note
                      _StatBadge(
                        icon: Icons.star_rounded,
                        iconColor: const Color(0xFFFFB800),
                        label:
                            '${shop.rating.toStringAsFixed(1)} (${shop.reviewCount} avis)',
                      ),
                      SizedBox(width: 10.w),
                      // CatÃƒÆ’Ã‚Â©gorie
                      _StatBadge(
                        icon: Icons.store_outlined,
                        iconColor: AppColors.primary,
                        label: shop.categoryIds.isNotEmpty
                            ? context
                                .read<CategoryService>()
                                .all
                                .firstWhere(
                                  (c) => c.id == shop.categoryIds.first,
                                  orElse: () => const CategoryModel(
                                    id: 0,
                                    labelKey: 'unknown',
                                    name: 'Unknown',
                                    icon: Icons.help_outline,
                                  ),
                                )
                                .name ?? 'Unknown'
                            : 'no_category'.tr(),
                      ),
                      SizedBox(width: 10.w),
                      // Produits
                      _StatBadge(
                        icon: Icons.inventory_2_outlined,
                        iconColor: AppColors.primary,
                        label: 'items_count'.tr(
                          args: [products.length.toString()],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'products'.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          products.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40.r),
                    child: Center(
                      child: Text(
                        'no_products_available'.tr(),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 4.h,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => ProductCardWidget(product: products[i]),
                      childCount: products.length,
                    ),
                  ),
                ),

          SliverToBoxAdapter(child: SizedBox(height: 30.h)),
        ],
      ),
    );
  }
}

class _ShopCover extends StatelessWidget {
  final ShopModel shop;
  const _ShopCover({required this.shop});

  @override
  Widget build(BuildContext context) {
    if (shop.imageUrl != null && shop.imageUrl!.isNotEmpty) {
      return Image.network(
        shop.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    color: AppColors.primary,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            color: Colors.white54,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez la photo de ${shop.name}',
            style: const TextStyle(color: Colors.white60, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.r, color: iconColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
