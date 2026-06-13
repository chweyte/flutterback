import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';

class CircularBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  
  const CircularBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () {
        // Go back to the first route (Home) or just pop
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 40.r,
        height: 40.r,
        margin: EdgeInsets.only(right: 12.w),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          size: 20.r,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
