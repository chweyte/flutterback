import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/commerce/category_model.dart';
import '../../core/theme/app_colors.dart';

class CategoryChipWidget extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChipWidget({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasVisual = category.imageAsset != null || category.imageUrl != null;

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(
              left: hasVisual ? 3.w : 14.w,
              right: 12.w,
              top: hasVisual ? 3.h : 9.h,
              bottom: hasVisual ? 3.h : 9.h,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x2E1C1C1E),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasVisual) ...[
                  ClipOval(
                    child: SizedBox(
                      width: 34.r,
                      height: 34.r,
                      child: _buildImage(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ] else ...[
                  Icon(
                    category.icon,
                    size: 14.r,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  SizedBox(width: 5.w),
                ],
                Text(
                  category.name ?? category.labelKey.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    // PrioritÃƒÂ© : asset local > URL rÃƒÂ©seau
    if (category.imageAsset != null) {
      return Image.asset(
        category.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _iconFallback(),
      );
    }
    return Image.network(
      category.imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _iconFallback(),
      errorBuilder: (_, __, ___) => _iconFallback(),
    );
  }

  Widget _iconFallback() => Container(
    color: AppColors.background,
    child: Center(
      child: Icon(category.icon, size: 14, color: AppColors.textSecondary),
    ),
  );
}
