import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'login_screen.dart';
import '../services/route_transitions.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9), // Light background
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
                  color: const Color(0xFF007AFF), // Blue primary
                ),
              ),
              SizedBox(height: 50.h),
              // Main Text
              Text(
                'Discover top products\nand start shopping\ntoday',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF1E293B), // Slate 800
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
                  color: const Color(0xFF64748B), // Slate 500
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              // Get started button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFF0055FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        SlidePageRoute(page: LoginScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
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
