import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'client_home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import '../../services/route_transitions.dart';
import '../login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _loading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String _selectedRole = 'client'; // 'client' or 'commercant'

  Future<void> _signup() async {
    setState(() => _loading = true);
    try {
      if (_selectedRole == 'client') {
        String? uid = await _auth.signupClient(
          _emailController.text.trim(),
          "", // Phone number removed intentionally
          _passwordController.text.trim(),
        );
        if (uid != null) {
          Navigator.pushReplacement(context,
              SlidePageRoute(page: ClientHome()));
        }
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Inscription commerçant en cours de développement.')));
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains(']')) {
        errorMsg = errorMsg.split(']').last.trim();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $errorMsg'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)));
    }
    setState(() => _loading = false);
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
            color: isSelected ? const Color(0xFF007AFF).withOpacity(0.08) : Colors.white,
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
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF007AFF).withOpacity(_loading ? 0.7 : 1.0),
                                  const Color(0xFF0055FF).withOpacity(_loading ? 0.7 : 1.0)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: _loading ? null : _signup,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
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