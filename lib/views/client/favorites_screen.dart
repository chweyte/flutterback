import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/commerce/product_model.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/favorites_service.dart';
import '../../views/widgets/product_card_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Text(
                    'favorites'.tr(),
                    style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<ProductModel>>(
                valueListenable: FavoritesService.instance.favorites,
                builder: (context, favs, _) {
                  if (favs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 60.r, color: AppColors.textLight),
                          SizedBox(height: 16.h),
                          Text(
                            'Appuyez sur Ã¢ÂÂ¤ pour ajouter des favoris',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14.sp),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 8.h),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: favs.length,
                    itemBuilder: (ctx, i) =>
                        ProductCardWidget(product: favs[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
