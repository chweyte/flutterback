import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'client_home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import '../../services/route_transitions.dart';
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
         _showToast('Inscription commerçant en cours de développement.', ToastificationType.info);
      }
    } catch (e) {
      String errorMsg = e.toString();
      
      // If we hit already-in-use, let's see if it's their previous unverified account
      if (errorMsg.contains('email-already-in-use')) {
        try {
          UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
             email: email,
             password: password
          );
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
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mark_email_unread_outlined, size: 48, color: Color(0xFF007AFF)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Verify your email',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We sent a verification link to your email. Please click the link to verify your account and then continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isChecking ? null : () async {
                        setBottomSheetState(() => isChecking = true);
                        User? user = FirebaseAuth.instance.currentUser;
                        await user?.reload();
                        user = FirebaseAuth.instance.currentUser; // get refreshed state
                        
                        if (user != null && user.emailVerified) {
                          await AuthService().ensureClientProfileExists(user.uid, user.email ?? '');
                          Navigator.pop(context); // close bottom sheet
                                  Navigator.pushReplacement(
                                    this.context,
                                    SlidePageRoute(page: ClientHome()),
                                  );
                                  _showToast('Email verified successfully!', ToastificationType.success);
                                } else {
                                  setBottomSheetState(() => isChecking = false);
                                  _showToast('Email not verified yet. Please check your inbox.', ToastificationType.warning);
                                }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        splashFactory: NoSplash.splashFactory,
                        shadowColor: Colors.transparent,
                      ),
                      child: isChecking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "I've verified my email",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: (_resendCooldown > 0 || isChecking) ? null : () {
                      FirebaseAuth.instance.currentUser?.sendEmailVerification();
                      _showToast('Verification link resent.', ToastificationType.info);
                      setBottomSheetState(() {
                        _resendCooldown = 300; // 5 minutes
                      });
                      _resendTimer?.cancel();
                      _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                        setBottomSheetState(() {
                          if (_resendCooldown > 0) {
                            _resendCooldown--;
                          } else {
                            timer.cancel();
                          }
                        });
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        _resendCooldown > 0 
                            ? 'Resend link ($_formattedCooldown)' 
                            : 'Resend link',
                        style: TextStyle(
                          color: _resendCooldown > 0 ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
          duration: isSelected ? const Duration(milliseconds: 200) : Duration.zero,
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF007AFF) : Colors.grey.shade200,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                assetPath,
                width: 26, 
                colorFilter: ColorFilter.mode(
                  isSelected ? const Color(0xFF007AFF) : const Color(0xFF64748B),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
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
                    padding: const EdgeInsets.fromLTRB(24.0, 60.0, 24.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.chevron_left, color: Color(0xFF1E293B)),
                                onPressed: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            const Expanded(
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Role Segment Control
                        Row(
                          children: [
                            _buildRoleSegment('client', 'assets/user.svg', 'Client'),
                            const SizedBox(width: 16),
                            _buildRoleSegment('commercant', 'assets/merchant.svg', 'Commerçant'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Email field
                        const Text(
                          'Your email address',
                          style: TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Color(0xFF1E293B)),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              hintText: 'e.g. username@gmail.com',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password field
                        const Text(
                          'Enter your password',
                          style: TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Color(0xFF1E293B)),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              hintText: '••••••••••••',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFF94A3B8), 
                                  size: 20
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Remember me
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? false;
                                  });
                                },
                                checkColor: Colors.white,
                                activeColor: const Color(0xFF007AFF),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Remember me', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Signup Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF007AFF).withOpacity((_loading || !_isValidEmail(_emailController.text.trim()) || _passwordController.text.isEmpty) ? 0.5 : 1.0),
                                  const Color(0xFF0055FF).withOpacity((_loading || !_isValidEmail(_emailController.text.trim()) || _passwordController.text.isEmpty) ? 0.5 : 1.0)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: (_loading || !_isValidEmail(_emailController.text.trim()) || _passwordController.text.isEmpty) ? null : _signup,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Sign up',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Or', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Google Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: SvgPicture.asset('assets/google.svg', width: 22),
                            label: const Text(
                              'Sign up with google',
                              style: TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      Navigator.pop(context);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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