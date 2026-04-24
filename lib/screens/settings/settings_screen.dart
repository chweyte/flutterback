import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../services/route_transitions.dart';
import '../landing_screen.dart';
import '../../services/auth_service.dart';

/// Settings / Profile screen.
/// Language change is applied via easy_localization – the whole app rebuilds
/// automatically (including RTL for Arabic).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const _languages = [
    {'code': 'fr', 'name': 'Français',  'flag': '🇫🇷'},
    {'code': 'ar', 'name': 'العربية',   'flag': '🇲🇷'},
    {'code': 'en', 'name': 'English',   'flag': '🇬🇧'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.displayName ?? user?.email?.split('@').first ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('settings'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.r),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile card ────────────────────────────────────────────
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      username.isNotEmpty
                          ? username[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Language section ─────────────────────────────────────────
            SizedBox(height: 24.h),
            Text(
              'language'.tr(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 10.h),
            ..._languages.map(
              (lang) => _LanguageTile(
                flag: lang['flag']!,
                name: lang['name']!,
                code: lang['code']!,
                isSelected: context.locale.languageCode == lang['code'],
                // Changing locale here triggers a full app rebuild + RTL for Arabic
                onTap: () => context.setLocale(Locale(lang['code']!)),
              ),
            ),

            const Spacer(),

            // ── Logout ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      SlidePageRoute(page: LandingScreen()),
                    );
                  }
                },
                icon: Icon(Icons.logout_rounded, size: 18.r),
                label: Text(
                  'logout'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String name;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.name,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 22.sp)),
            SizedBox(width: 12.w),
            Text(
              name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.r),
          ],
        ),
      ),
    );
  }
}
