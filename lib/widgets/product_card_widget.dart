import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/theme/app_colors.dart';

class ProductCardWidget extends StatefulWidget {
  final String name;
  final String price;
  final String? imageUrl;
  final bool isDark;
  final VoidCallback? onAddToCart;

  const ProductCardWidget({
    super.key,
    required this.name,
    required this.price,
    this.imageUrl,
    this.isDark = false,
    this.onAddToCart,
  });

  @override
  State<ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<ProductCardWidget> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = widget.isDark ? Colors.white : AppColors.textPrimary;
    final subColor  = widget.isDark ? Colors.white60 : AppColors.textSecondary;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: widget.isDark
              ? const []
              : [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.06),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: widget.isDark
                          ? const Color(0xFF2C2C2E)
                          : AppColors.background,
                      child: Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 34.r,
                          color: widget.isDark
                              ? const Color(0x40FFFFFF)
                              : AppColors.textLight,
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _isFavorite = !_isFavorite),
                        child: Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: const BoxDecoration(
                            color: Color(0xF2FFFFFF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 13.r,
                            color: _isFavorite
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Info ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(9.w, 7.h, 9.w, 9.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'in_stock'.tr(),
                    style: TextStyle(fontSize: 9.sp, color: subColor),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.price,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: widget.onAddToCart,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? Colors.white
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            widget.isDark
                                ? 'shop_now'.tr()
                                : 'add_to_cart'.tr(),
                            style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark
                                  ? AppColors.primary
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
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
