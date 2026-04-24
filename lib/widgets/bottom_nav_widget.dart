import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/theme/app_colors.dart';

/// Floating dark bottom navigation bar.
/// The active item expands to show its label; inactive items show only icons.
class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int cartCount;

  const BottomNavWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(Icons.home_rounded, 'home'.tr(), null),
      _NavItemData(Icons.search_rounded, 'search'.tr(), null),
      _NavItemData(Icons.favorite_border_rounded, 'favorites'.tr(), null),
      _NavItemData(Icons.notifications_none_rounded, 'notifications'.tr(), null),
      _NavItemData(Icons.person_outline_rounded, 'profile'.tr(), null),
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
        children: List.generate(
          items.length,
          (i) => _NavItem(
            data: items[i],
            isActive: i == currentIndex,
            onTap: () => onTap(i),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final int? badge;
  _NavItemData(this.icon, this.label, this.badge);
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14.w : 8.w,
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
            Icon(
              data.icon,
              color: isActive ? Colors.white : Colors.white54,
              size: 20.r,
            ),
            if (isActive) ...[
              SizedBox(width: 5.w),
              Text(
                data.label,
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
  }
}
