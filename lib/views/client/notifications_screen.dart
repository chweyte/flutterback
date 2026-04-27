import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _notifs = [
    {
      'title': 'Nouvelle promotion !',
      'body': 'Profitez de -20% sur les parfums ce weekend.',
      'time': 'Il y a 2h',
      'read': false,
      'icon': Icons.local_offer_outlined,
    },
    {
      'title': 'Commande confirmÃ©e',
      'body': 'Votre commande #1042 a Ã©tÃ© confirmÃ©e.',
      'time': 'Hier',
      'read': true,
      'icon': Icons.check_circle_outline_rounded,
    },
    {
      'title': 'Nouveau produit',
      'body': 'DÃ©couvrez la nouvelle collection Daraa 2026.',
      'time': '24 Avr',
      'read': true,
      'icon': Icons.new_releases_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                  Text(
                    'notifications'.tr(),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                physics: const ClampingScrollPhysics(),
                itemCount: _notifs.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (ctx, i) {
                  final n = _notifs[i];
                  final isRead = n['read'] as bool;
                  return Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: isRead ? AppColors.surface : AppColors.primary,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: isRead
                                ? AppColors.background
                                : const Color(0x26FFFFFF),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            n['icon'] as IconData,
                            size: 20.r,
                            color: isRead ? AppColors.textPrimary : Colors.white,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n['title'] as String,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isRead
                                      ? AppColors.textPrimary
                                      : Colors.white,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                n['body'] as String,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isRead
                                      ? AppColors.textSecondary
                                      : Colors.white70,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                n['time'] as String,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: isRead
                                      ? AppColors.textLight
                                      : Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
