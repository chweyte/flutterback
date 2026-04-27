import '../../controllers/category_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/commerce/category_model.dart';
import '../../core/theme/app_colors.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

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
                  Text(
                    'categories'.tr(),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 1.4,
                ),
                itemCount: context.watch<CategoryService>().all.length,
                itemBuilder: (ctx, i) => _CategoryCard(category: context.watch<CategoryService>().all[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  const _CategoryCard({required this.category});

  static const _palette = [
    Color(0xFF1C1C1E),
    Color(0xFF3A3A3C),
    Color(0xFF48484A),
    Color(0xFF636366),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = context.watch<CategoryService>().all.indexOf(category);
    final bg = _palette[idx % _palette.length];
    final isLight = bg.computeLuminance() > 0.3;
    final fgColor = isLight ? AppColors.textPrimary : Colors.white;
    final iconBg = isLight
        ? const Color(0x15000000)
        : const Color(0x20FFFFFF);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18.r),
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(category.icon, size: 20.r, color: fgColor),
          ),
          Text(
            category.labelKey.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
