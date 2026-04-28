import '../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../controllers/route_transitions.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Light background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0.w, vertical: 40.0.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Placeholder for Logo
              Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 150.r,
                  color: AppColors.primary, // Blue primary
                ),
              ),
              SizedBox(height: 50.h),
              // Main Text
              Text(
                'Discover top products\nand start shopping\ntoday',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary, // Slate 800
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 16.h),
              // Sub text
              Text(
                'Start your shopping journey and unlock new\ndeals',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary, // Slate 500
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              // Get started button
              SizedBox(
                width: double.infinity,
                height: 42.h,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('has_seen_landing', true);
                      Navigator.pushReplacement(
                        context,
                        SlidePageRoute(page: const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Get started',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
