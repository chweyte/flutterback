import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/commerce/product_model.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/favorites_service.dart';
import '../../controllers/route_transitions.dart';
import '../client/product_detail_screen.dart';

class ProductCardWidget extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onAddToCart;

  const ProductCardWidget({super.key, required this.product, this.onAddToCart});

  @override
  State<ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<ProductCardWidget> {
  final _fav = FavoritesService.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.product.isDark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subColor = isDark ? Colors.white60 : AppColors.textSecondary;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          SlidePageRoute(page: ProductDetailScreen(product: widget.product)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: isDark
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ã¢â€â‚¬Ã¢â€â‚¬ Image Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Product image Ã¢â‚¬â€ asset local prioritaire sur URL rÃƒÂ©seau
                      if (widget.product.imageAsset != null)
                        Image.asset(
                          widget.product.imageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _Placeholder(isDark: isDark),
                        )
                      else if (widget.product.imageUrl != null)
                        Image.network(
                          widget.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _Placeholder(isDark: isDark),
                        )
                      else
                        _Placeholder(isDark: isDark),

                      // Favorite button Ã¢â‚¬â€œ connected to FavoritesService
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: ValueListenableBuilder<List<ProductModel>>(
                          valueListenable: _fav.favorites,
                          builder: (_, favs, __) {
                            final isFav = _fav.isFavorite(widget.product.id);
                            return GestureDetector(
                              onTap: () => _fav.toggle(widget.product),
                              child: Container(
                                padding: EdgeInsets.all(5.r),
                                decoration: const BoxDecoration(
                                  color: Color(0xF2FFFFFF),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 13.r,
                                  color: isFav
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Ã¢â€â‚¬Ã¢â€â‚¬ Info Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
              Padding(
                padding: EdgeInsets.fromLTRB(9.w, 7.h, 9.w, 9.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.product.name,
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
                            widget.product.price,
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
                              horizontal: 7.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : AppColors.primary,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              isDark ? 'shop_now'.tr() : 'add_to_cart'.tr(),
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
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
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final bool isDark;
  const _Placeholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF2C2C2E) : AppColors.background,
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 34,
          color: isDark ? const Color(0x40FFFFFF) : AppColors.textLight,
        ),
      ),
    );
  }
}
