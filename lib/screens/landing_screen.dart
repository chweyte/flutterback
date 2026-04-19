import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/route_transitions.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9), // Light background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Placeholder for Logo
              Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 150,
                  color: const Color(0xFF007AFF), // Blue primary
                ),
              ),
              const SizedBox(height: 50),
              // Main Text
              const Text(
                'Discover top products\nand start shopping\ntoday',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1E293B), // Slate 800
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              // Sub text
              const Text(
                'Start your shopping journey and unlock new\ndeals',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B), // Slate 500
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              // Get started button
              SizedBox(
                width: double.infinity,
                height: 50,
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
