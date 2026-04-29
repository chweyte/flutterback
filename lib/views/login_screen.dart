import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/auth_service.dart';
import 'admin/admin_home.dart';
import 'commercant/change_password_screen.dart';
import 'commercant/commercant_home.dart';
import '../models/users/commercant.dart';
import 'client/signup_screen.dart';
import 'client/client_home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import '../controllers/route_transitions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetEmailController = TextEditingController(); // Moved to class level
  final AuthService _auth = AuthService();
  bool _loading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  Timer? _resendTimer;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
    _resetEmailController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_onInputChanged);
    _passwordController.removeListener(_onInputChanged);
    _resetEmailController.removeListener(_onInputChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showToast(String message, ToastificationType type) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flatColored,
      title: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
      autoCloseDuration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 300),
      alignment: Alignment.topRight,
    );
  }

  String get _formattedCooldown {
    int minutes = _resendCooldown ~/ 60;
    int seconds = _resendCooldown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _loading = true);
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // 1. Unified Authentication
      final user = await _auth.signIn(email, password);
      if (user == null) {
        _showToast('Email ou mot de passe incorrect', ToastificationType.error);
        setState(() => _loading = false);
        return;
      }

      // 2. Fetch Role and Redirect
      final role = await _auth.getUserRole(user.id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role ?? 'client');
      await prefs.setString('user_id', user.id);

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          SlidePageRoute(page: const AdminHome()),
        );
      } else if (role == 'commercant') {
        // Fetch merchant details
        final merchant = await _auth.loginCommercant(email, password);
        if (merchant != null && merchant.premiereConnexion) {
          Navigator.pushReplacement(
            context,
            SlidePageRoute(
              page: ChangePasswordScreen(commercantId: merchant.id),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            SlidePageRoute(page: const CommercantHome()),
          );
        }
      } else {
        // Default to client
        Navigator.pushReplacement(context, SlidePageRoute(page: ClientHome()));
      }
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        _showVerificationBottomSheet();
      } else {
        _showToast(e.message, ToastificationType.error);
      }
    } catch (e) {
      _showToast('Une erreur est survenue', ToastificationType.error);
      print('Login error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    _showToast(msg, ToastificationType.error);
  }

  void _showForgotPasswordBottomSheet() {
    bool isSending = false;
    bool isSent = false;

    _resendTimer?.cancel();
    _resendCooldown = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 32.h,
                left: 24.w,
                right: 24.w,
                top: 24.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 24.h),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  if (!isSent) ...[
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter your email address and we will send you a password reset link.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Your email address',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 50.h,
                      child: TextField(
                        controller: _resetEmailController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 0,
                          ),
                          hintText: 'e.g. username@gmail.com',
                          hintStyle: const TextStyle(
                            color: AppColors.textLight,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.textLight,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: AnimatedBuilder(
                        animation: _resetEmailController,
                        builder: (context, child) {
                          bool isDisabled =
                              isSending ||
                              !_isValidEmail(_resetEmailController.text.trim());
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(
                                    isDisabled ? 0.5 : 1.0,
                                  ),
                                  AppColors.primary.withOpacity(
                                    isDisabled ? 0.5 : 1.0,
                                  ),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: ElevatedButton(
                              onPressed: isDisabled
                                  ? null
                                  : () async {
                                      String email = _resetEmailController.text
                                          .trim();
                                      if (email.isEmpty) return;
                                      setBottomSheetState(
                                        () => isSending = true,
                                      );
                                      try {
                                        await _auth.resetPassword(email);
                                        setBottomSheetState(() {
                                          isSending = false;
                                          isSent = true;
                                          _resendCooldown = 300;
                                        });
                                        _showToast(
                                          'Reset link sent!',
                                          ToastificationType.success,
                                        );
                                        _resendTimer?.cancel();
                                        _resendTimer = Timer.periodic(
                                          const Duration(seconds: 1),
                                          (timer) {
                                            setBottomSheetState(() {
                                              if (_resendCooldown > 0) {
                                                _resendCooldown--;
                                              } else {
                                                timer.cancel();
                                              }
                                            });
                                          },
                                        );
                                      } catch (e) {
                                        setBottomSheetState(
                                          () => isSending = false,
                                        );
                                        _showToast(
                                          'Error: ${e.toString()}',
                                          ToastificationType.error,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: isSending
                                  ? SizedBox(
                                      height: 20.r,
                                      width: 20.r,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Send Link',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mark_email_unread_outlined,
                              size: 48.r,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Check your email',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'We sent a password reset link to your email.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          SizedBox(
                            width: double.infinity,
                            height: 42.h,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                elevation: 0,
                                splashFactory: NoSplash.splashFactory,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'Back to Login',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _resendCooldown > 0
                                ? null
                                : () async {
                                    await _auth.resetPassword(
                                      _resetEmailController.text.trim(),
                                    );
                                    _showToast(
                                      'Password reset link resent.',
                                      ToastificationType.success,
                                    );
                                    setBottomSheetState(() {
                                      _resendCooldown = 300;
                                    });
                                    _resendTimer?.cancel();
                                    _resendTimer = Timer.periodic(
                                      const Duration(seconds: 1),
                                      (timer) {
                                        setBottomSheetState(() {
                                          if (_resendCooldown > 0) {
                                            _resendCooldown--;
                                          } else {
                                            timer.cancel();
                                          }
                                        });
                                      },
                                    );
                                  },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8.0.h,
                                horizontal: 16.0.w,
                              ),
                              child: Text(
                                _resendCooldown > 0
                                    ? 'Resend link ($_formattedCooldown)'
                                    : 'Resend link',
                                style: TextStyle(
                                  color: _resendCooldown > 0
                                      ? AppColors.textLight
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showVerificationBottomSheet() {
    bool isVerifying = false;
    final otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
                left: 24.w,
                right: 24.w,
                top: 24.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.vibration_outlined,
                      size: 48.r,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Verification Code',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please enter the 6-digit code sent to\n${_emailController.text.trim()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "000000",
                      hintStyle: TextStyle(
                        color: AppColors.textLight.withOpacity(0.3),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: isVerifying
                          ? null
                          : () async {
                              final code = otpController.text.trim();
                              if (code.length != 6) {
                                _showToast(
                                  'Please enter a 6-digit code',
                                  ToastificationType.warning,
                                );
                                return;
                              }

                              setBottomSheetState(() => isVerifying = true);
                              try {
                                final response = await _auth.verifyOtp(
                                  _emailController.text.trim(),
                                  code,
                                );

                                if (response.user != null) {
                                  // For login, we might not have the fullname handy if they didn't sign up just now
                                  // But ensureClientProfileExists will fetch it if it exists or use email
                                  await _auth.ensureClientProfileExists(
                                    response.user!.id,
                                    response.user!.email ?? '',
                                    response.user!.userMetadata?['fullname'] ??
                                        '',
                                  );

                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    this.context,
                                    SlidePageRoute(page: ClientHome()),
                                  );
                                  _showToast(
                                    'Welcome back!',
                                    ToastificationType.success,
                                  );
                                }
                              } catch (e) {
                                setBottomSheetState(() => isVerifying = false);
                                _showToast(
                                  'Invalid or expired code',
                                  ToastificationType.error,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: isVerifying
                          ? SizedBox(
                              height: 20.r,
                              width: 20.r,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Verify Account',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: _resendCooldown > 0
                        ? null
                        : () async {
                            try {
                              await _auth.sendOtp(_emailController.text.trim());
                              _showToast(
                                'Code resent!',
                                ToastificationType.info,
                              );
                              setBottomSheetState(() => _resendCooldown = 60);
                              _resendTimer?.cancel();
                              _resendTimer = Timer.periodic(
                                const Duration(seconds: 1),
                                (timer) {
                                  setBottomSheetState(() {
                                    if (_resendCooldown > 0) {
                                      _resendCooldown--;
                                    } else {
                                      timer.cancel();
                                    }
                                  });
                                },
                              );
                            } catch (e) {
                              _showToast(
                                'Error resending code',
                                ToastificationType.error,
                              );
                            }
                          },
                    child: Text(
                      _resendCooldown > 0
                          ? 'Resend code in $_resendCooldown s'
                          : 'Resend Code',
                      style: TextStyle(
                        color: _resendCooldown > 0
                            ? AppColors.textLight
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: _resendCooldown > 0
                            ? TextDecoration.none
                            : TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24.0.w,
                      60.0.h,
                      24.0.w,
                      20.0.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 42.h,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Email field
                        Text(
                          'Your email address',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 50.h,
                          child: TextField(
                            controller: _emailController,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 0,
                              ),
                              hintText: 'e.g. username@gmail.com',
                              hintStyle: const TextStyle(
                                color: AppColors.textLight,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.textLight,
                                size: 24.r,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Password field
                        Text(
                          'Enter your password',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 50.h,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 0,
                              ),
                              hintText: '••••••••••••',
                              hintStyle: const TextStyle(
                                color: AppColors.textLight,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.textLight,
                                size: 24.r,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textLight,
                                  size: 20.r,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Remember me & Forget password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (val) {
                                      setState(() {
                                        _rememberMe = val ?? false;
                                      });
                                    },
                                    checkColor: Colors.white,
                                    activeColor: AppColors.primary,
                                    side: BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _showForgotPasswordBottomSheet,
                              child: Text(
                                'Forget password',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.sp,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 42.h,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(
                                    (_loading ||
                                            !_isValidEmail(
                                              _emailController.text.trim(),
                                            ) ||
                                            _passwordController.text.isEmpty)
                                        ? 0.5
                                        : 1.0,
                                  ),
                                  AppColors.primary.withOpacity(
                                    (_loading ||
                                            !_isValidEmail(
                                              _emailController.text.trim(),
                                            ) ||
                                            _passwordController.text.isEmpty)
                                        ? 0.5
                                        : 1.0,
                                  ),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  (_loading ||
                                      !_isValidEmail(
                                        _emailController.text.trim(),
                                      ) ||
                                      _passwordController.text.isEmpty)
                                  ? null
                                  : _login,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: _loading
                                  ? SizedBox(
                                      height: 18.r,
                                      width: 18.r,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Log In',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.border,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'Or',
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.border,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Google Button
                        SizedBox(
                          width: double.infinity,
                          height: 42.h,
                          child: ElevatedButton.icon(
                            onPressed: () => _auth.signInWithGoogle(),
                            icon: SvgPicture.asset(
                              'assets/google.svg',
                              width: 22.w,
                            ),
                            label: Text(
                              'Sign up with google',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                side: BorderSide(color: AppColors.border),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Create account
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: 'SignUp',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      Navigator.push(
                                        context,
                                        SlidePageRoute(page: SignupScreen()),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
