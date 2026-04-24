import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/models/shop_model.dart';
import '../../core/theme/app_colors.dart';
import '../../services/route_transitions.dart';
import 'shop_detail_screen.dart';

class ShopsScreen extends StatelessWidget {
  const ShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16.r, color: AppColors.textPrimary),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'boutiques'.tr(),
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${allShops.length} boutiques disponibles',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Liste des boutiques ─────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                itemCount: allShops.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (ctx, i) => _ShopCard(
                  shop: allShops[i],
                  onTap: () => Navigator.push(
                    ctx,
                    SlidePageRoute(
                        page: ShopDetailScreen(shop: allShops[i])),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onTap;
  const _ShopCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final productCount =
        allShops.indexOf(shop) >= 0 ? _productCountForShop(shop.id) : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo boutique
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(18.r)),
              child: SizedBox(
                width: 90.w,
                height: 90.h,
                child: _ShopImage(shop: shop),
              ),
            ),
            SizedBox(width: 14.w),
            // Infos
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    shop.description,
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      // Note
                      Icon(Icons.star_rounded,
                          size: 13.r, color: const Color(0xFFFFB800)),
                      SizedBox(width: 3.w),
                      Text(
                        shop.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(${shop.reviewCount})',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      // Nb produits
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '$productCount produits',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Image de boutique : asset local > URL réseau > placeholder lettrine
class _ShopImage extends StatelessWidget {
  final ShopModel shop;
  const _ShopImage({required this.shop});

  @override
  Widget build(BuildContext context) {
    if (shop.imageAsset != null) {
      return Image.asset(
        shop.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _LogoPlaceholder(name: shop.name),
      );
    }
    if (shop.imageUrl != null) {
      return Image.network(
        shop.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _LogoPlaceholder(name: shop.name),
      );
    }
    return _LogoPlaceholder(name: shop.name);
  }
}

class _LogoPlaceholder extends StatelessWidget {
  final String name;
  const _LogoPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'S',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

int _productCountForShop(String shopId) => _cachedCounts[shopId] ?? 0;

const Map<String, int> _cachedCounts = {
  'shop_bellah': 10,
  'shop_homme': 4,
  'shop_2': 1,
  'shop_3': 2,
  'shop_4': 4,
  'shop_5': 4,
  'shop_6': 3,
};
