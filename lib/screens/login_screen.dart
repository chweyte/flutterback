import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/auth_service.dart';
import 'admin/admin_home.dart';
import 'commercant/change_password_screen.dart';
import 'commercant/commercant_home.dart';
import '../models/commercant.dart';
import 'client/signup_screen.dart';
import 'client/client_home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import '../services/route_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends StatefulWidget {
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

    // 1. Check Admin
    String? adminRole = await _auth.loginAdmin(email, password);
    if (adminRole != null) {
      Navigator.pushReplacement(context, SlidePageRoute(page: AdminHome()));
      return;
    }

    // 2. Check Commerçant
    Commercant? commercantResult = await _auth.loginCommercant(
      email,
      password,
    );
    if (commercantResult != null) {
      if (commercantResult.premiereConnexion) {
        Navigator.pushReplacement(
          context,
          SlidePageRoute(
            page: ChangePasswordScreen(commercantId: commercantResult.id),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          SlidePageRoute(page: CommercantHome()),
        );
      }
      return;
    }

    // 3. Check Client
    try {
      String? uid = await _auth.loginClient(email, password);
      if (uid != null) {
        Navigator.pushReplacement(context, SlidePageRoute(page: ClientHome()));
        return;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'unverified-email') {
        setState(() => _loading = false);
        _showVerificationBottomSheet();
        return;
      }
    } catch (e) {
      // Pour les autres erreurs, on laissera tomber dans l'erreur générique ci-dessous
    }

    // Si on arrive ici, rien n'a marché
    _showToast('Email ou mot de passe incorrect', ToastificationType.error);
    setState(() => _loading = false);
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
                        color: Colors.grey.shade300,
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
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter your email address and we will send you a password reset link.',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Your email address',
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 50.h,
                      child: TextField(
                        controller: _resetEmailController,
                        style: const TextStyle(color: Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 0,
                          ),
                          hintText: 'e.g. username@gmail.com',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF94A3B8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF007AFF),
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
                                  const Color(
                                    0xFF007AFF,
                                  ).withOpacity(isDisabled ? 0.5 : 1.0),
                                  const Color(
                                    0xFF0055FF,
                                  ).withOpacity(isDisabled ? 0.5 : 1.0),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: isSending
                                  ? SizedBox(
                                      height: 20.h,
                                      width: 20.w,
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
                              color: const Color(0xFF007AFF).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mark_email_unread_outlined,
                              size: 48.r,
                              color: const Color(0xFF007AFF),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Check your email',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'We sent a password reset link to your email.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007AFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
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
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
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
    bool isChecking = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
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
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 48.r,
                      color: const Color(0xFF007AFF),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Verify your email',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'We sent a verification link to your email. Please click the link to verify your account and then continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: isChecking
                          ? null
                          : () async {
                              setBottomSheetState(() => isChecking = true);
                              User? user = FirebaseAuth.instance.currentUser;
                              await user?.reload();
                              user = FirebaseAuth.instance.currentUser;

                              if (user != null && user.emailVerified) {
                                await AuthService().ensureClientProfileExists(
                                  user.uid,
                                  user.email ?? '',
                                );
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  this.context,
                                  SlidePageRoute(page: ClientHome()),
                                );
                                _showToast(
                                  'Email verified successfully!',
                                  ToastificationType.success,
                                );
                              } else {
                                setBottomSheetState(() => isChecking = false);
                                _showToast(
                                  'Email not verified yet. Please check your inbox.',
                                  ToastificationType.warning,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                        splashFactory: NoSplash.splashFactory,
                        shadowColor: Colors.transparent,
                      ),
                      child: isChecking
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "I've verified my email",
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
                    onTap: (_resendCooldown > 0 || isChecking)
                        ? null
                        : () {
                            FirebaseAuth.instance.currentUser
                                ?.sendEmailVerification();
                            _showToast(
                              'Verification link resent.',
                              ToastificationType.info,
                            );
                            setBottomSheetState(() {
                              _resendCooldown = 300; // 5 minutes
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
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
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
      backgroundColor: const Color(0xFFF7F7F9),
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
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Email field
                        Text(
                          'Your number & email address',
                          style: TextStyle(
                            color: const Color(0xFF1E293B),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 50.h,
                          child: TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Color(0xFF1E293B)),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 0,
                              ),
                              hintText: 'e.g. username@gmail.com',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFF007AFF),
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
                            color: const Color(0xFF1E293B),
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
                            style: const TextStyle(color: Color(0xFF1E293B)),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 0,
                              ),
                              hintText: '••••••••••••',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF94A3B8),
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
                                  color: const Color(0xFF94A3B8),
                                  size: 20.r,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFF007AFF),
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
                                    activeColor: const Color(0xFF007AFF),
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: const Color(0xFF64748B),
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _showForgotPasswordBottomSheet,
                              style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                                padding: EdgeInsets.zero,
                                minimumSize: Size(50.w, 30.h),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forget password',
                                style: TextStyle(
                                  color: const Color(0xFF007AFF),
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF007AFF).withOpacity(
                                    (_loading ||
                                            !_isValidEmail(
                                              _emailController.text.trim(),
                                            ) ||
                                            _passwordController.text.isEmpty)
                                        ? 0.5
                                        : 1.0,
                                  ),
                                  const Color(0xFF0055FF).withOpacity(
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
                              borderRadius: BorderRadius.circular(12.r),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: _loading
                                  ? SizedBox(
                                      height: 20.h,
                                      width: 20.w,
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
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'Or',
                                style: TextStyle(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Google Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: SvgPicture.asset(
                              'assets/google.svg',
                              width: 22.w,
                            ),
                            label: Text(
                              'Sign up with google',
                              style: TextStyle(
                                color: const Color(0xFF1E293B),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                side: BorderSide(color: Colors.grey.shade200),
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
                                color: const Color(0xFF64748B),
                                fontSize: 13.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: 'SignUp',
                                  style: const TextStyle(
                                    color: Color(0xFF007AFF),
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
