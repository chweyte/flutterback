import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load local storage notifications
    NotificationService.instance.load();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'offer':
        return Icons.local_offer_outlined;
      case 'success':
        return Icons.check_circle_outline_rounded;
      case 'new':
        return Icons.new_releases_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

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
                  Text(
                    'notifications'.tr(),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => NotificationService.instance.clearAll(),
                    child: Icon(
                      Icons.delete_outline,
                      size: 24.r,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: AnimatedBuilder(
                animation: NotificationService.instance,
                builder: (context, _) {
                  final notifs = NotificationService.instance.items;

                  if (notifs.isEmpty) {
                    return Center(
                      child: Text(
                        'no_notifications'.tr(),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16.sp,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    physics: const ClampingScrollPhysics(),
                    itemCount: notifs.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (ctx, i) {
                      final n = notifs[i];
                      return GestureDetector(
                        onTap: () => NotificationService.instance.markAsRead(i),
                        child: Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: n.read
                                ? AppColors.surface
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: n.read
                                      ? AppColors.background
                                      : const Color(0x26FFFFFF),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  _getIconForType(n.iconType),
                                  size: 20.r,
                                  color: n.read
                                      ? AppColors.textPrimary
                                      : Colors.white,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: n.read
                                            ? AppColors.textPrimary
                                            : Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      n.body,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: n.read
                                            ? AppColors.textSecondary
                                            : Colors.white70,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      n.time,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: n.read
                                            ? AppColors.textLight
                                            : Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
