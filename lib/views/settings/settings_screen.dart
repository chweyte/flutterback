import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/route_transitions.dart';
import '../login_screen.dart';
import '../../controllers/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const _languages = [
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇲🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username =
        user?.displayName ?? user?.email?.split('@').first ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('profile'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.r),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            // Orders & Addresses Section
            Text(
              'my_account'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12.h),
            _buildActionTile(
              icon: Icons.shopping_bag_outlined,
              title: 'my_orders'.tr(),
            ),
            _buildActionTile(
              icon: Icons.location_on_outlined,
              title: 'shipping_addresses'.tr(),
            ),
            _buildActionTile(
              icon: Icons.payment_outlined,
              title: 'payment_methods'.tr(),
            ),
            SizedBox(height: 24.h),

            // Language section
            Text(
              'language'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12.h),
            ..._languages.map(
              (lang) => _LanguageTile(
                flag: lang['flag']!,
                name: lang['name']!,
                code: lang['code']!,
                isSelected: context.locale.languageCode == lang['code'],
                onTap: () => context.setLocale(Locale(lang['code']!)),
              ),
            ),

            SizedBox(height: 30.h),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      SlidePageRoute(page: LoginScreen()),
                    );
                  }
                },
                icon: Icon(Icons.logout_rounded, size: 20.r),
                label: Text(
                  'logout'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF0F0),
                  foregroundColor: const Color(
                    0xFFE53935,
                  ), // Red color for logout
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22.r),
          SizedBox(width: 14.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textLight,
            size: 16.r,
          ),
        ],
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
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 22.sp)),
            SizedBox(width: 16.w),
            Text(
              name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 22.r),
          ],
        ),
      ),
    );
  }
}
