import '../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/auth_service.dart';
import 'client_home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import '../../controllers/route_transitions.dart';
import '../login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static final _emailController = TextEditingController();
  static final _passwordController = TextEditingController();
  static String _selectedRole = 'client'; // 'client' or 'commercant'
  static bool _rememberMe = false;

  final AuthService _auth = AuthService();
  bool _loading = false;
  bool _obscurePassword = true;
  Timer? _resendTimer;
  int _resendCooldown = 0;
  String? _lastSubmittedEmail;
  String? _lastSubmittedPassword;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
    // After the first frame, check if we should automatically show verification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        // If the current inputs match the logged in user, reopen the sheet
        if (_emailController.text.trim() == user.email) {
          _showVerificationBottomSheet();
        }
      }
    });
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
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

  @override
  void dispose() {
    _emailController.removeListener(_onInputChanged);
    _passwordController.removeListener(_onInputChanged);
    // We don't dispose static controllers here because we want them to persist
    _resendTimer?.cancel();
    super.dispose();
  }

  String get _formattedCooldown {
    int minutes = _resendCooldown ~/ 60;
    int seconds = _resendCooldown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _signup() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _loading = true);
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // 1. Check if we currently have an unverified session
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && !currentUser.emailVerified) {
      // If they changed nothing, just reopen the sheet!
      if (email == _lastSubmittedEmail && password == _lastSubmittedPassword) {
        setState(() => _loading = false);
        _showVerificationBottomSheet();
        return;
      } else {
        // They changed the input. Delete the old unverified account!
        try {
          await currentUser.delete();
        } catch (e) {
          print("Could not delete previous unverified user: $e");
        }
      }
    }

    try {
      if (_selectedRole == 'client') {
        String? uid = await _auth.signupClient(
          email,
          "", // Phone number removed intentionally
          password,
        );
        if (uid != null) {
          _lastSubmittedEmail = email;
          _lastSubmittedPassword = password;
          _showVerificationBottomSheet();
        }
      } else {
        _showToast(
          'Inscription commerÃƒÂ§ant en cours de dÃƒÂ©veloppement.',
          ToastificationType.info,
        );
      }
    } catch (e) {
      String errorMsg = e.toString();

      // If we hit already-in-use, let's see if it's their previous unverified account
      if (errorMsg.contains('email-already-in-use')) {
        try {
          UserCredential cred = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          if (!cred.user!.emailVerified) {
            _lastSubmittedEmail = email;
            _lastSubmittedPassword = password;
            setState(() => _loading = false);
            _showVerificationBottomSheet();
            return; // Successfully reopened!
          } else {
            errorMsg = "This account is already verified. Please go to Login.";
          }
        } catch (_) {
          errorMsg = "Email is already in use by another account.";
        }
      } else {
        if (errorMsg.contains(']')) {
          errorMsg = errorMsg.split(']').last.trim();
        }
      }
      _showToast('Erreur : $errorMsg', ToastificationType.error);
    }
    setState(() => _loading = false);
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
                      Icons.mark_email_unread_outlined,
                      size: 48.r,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Verify your email',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'We sent a verification link to your email. Please click the link to verify your account and then continue.',
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
                      onPressed: isChecking
                          ? null
                          : () async {
                              setBottomSheetState(() => isChecking = true);
                              User? user = FirebaseAuth.instance.currentUser;
                              await user?.reload();
                              user = FirebaseAuth
                                  .instance
                                  .currentUser; // get refreshed state

                              if (user != null && user.emailVerified) {
                                await AuthService().ensureClientProfileExists(
                                  user.uid,
                                  user.email ?? '',
                                );
                                Navigator.pop(context); // close bottom sheet
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
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                        splashFactory: NoSplash.splashFactory,
                        shadowColor: Colors.transparent,
                      ),
                      child: isChecking
                          ? SizedBox(
                              height: 18.r,
                              width: 18.r,
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
                              ? AppColors.textLight
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          decoration: _resendCooldown > 0
                              ? TextDecoration.none
                              : TextDecoration.underline,
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

  Widget _buildRoleSegment(String role, String assetPath, String title) {
    bool isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: isSelected
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                assetPath,
                width: 26.w,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
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
                        // Header
                        SizedBox(
                          height: 42.h,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 42.h,
                                height: 42.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.chevron_left,
                                    color: AppColors.textPrimary,
                                    size: 24.r,
                                  ),
                                  onPressed: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
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
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.textLight,
                                size: 24.r,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.border,
                                ),
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
                            style: const TextStyle(color: AppColors.textPrimary),
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
                                borderSide: BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.border,
                                ),
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

                        // Remember me
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
                        SizedBox(height: 24.h),

                        // Signup Button
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
                                  : _signup,
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
                                      'Sign up',
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
                            onPressed: () {},
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
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                side: BorderSide(color: AppColors.border),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Login
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      Navigator.pop(context);
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
