import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/theme/app_colors.dart';

/// Floating dark bottom navigation: Home / Search / Favorites / Notifications / Cart
class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int cartCount;

  const BottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final labels = [
      'home'.tr(),
      'search'.tr(),
      'favorites'.tr(),
      'notifications'.tr(),
      'Mon Panier',
    ];
    const icons = [
      Icons.home_rounded,
      Icons.search_rounded,
      Icons.favorite_border_rounded,
      Icons.notifications_none_rounded,
      Icons.shopping_bag_outlined,
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (i) {
          final isActive = i == currentIndex;
          // Cart badge
          final showBadge = i == 4 && cartCount > 0;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 12.w : 7.w,
                vertical: 7.h,
              ),
              decoration: isActive
                  ? BoxDecoration(
                      color: const Color(0x26FFFFFF),
                      borderRadius: BorderRadius.circular(20.r),
                    )
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        icons[i],
                        color: isActive ? Colors.white : Colors.white54,
                        size: 20.r,
                      ),
                      if (showBadge)
                        Positioned(
                          top: -4.r,
                          right: -4.r,
                          child: Container(
                            width: 14.r,
                            height: 14.r,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$cartCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isActive) ...[
                    SizedBox(width: 5.w),
                    Text(
                      labels[i],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
