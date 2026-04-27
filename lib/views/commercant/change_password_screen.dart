import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/auth_service.dart';
import 'commercant_home.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String commercantId;
  ChangePasswordScreen({required this.commercantId});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newCodeController = TextEditingController();
  final _confirmCodeController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _loading = false;

  Future<void> _changeCode() async {
    if (_newCodeController.text != _confirmCodeController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les codes ne correspondent pas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await _auth.changerCodeCommercant(
      widget.commercantId,
      _newCodeController.text.trim(),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CommercantHome()),
    );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.indigo.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0.r),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.0.w,
                    vertical: 40.0.h,
                  ),
                  child: Container(
                    width: constraints_box_width_check(
                      400.w,
                    ), // Using a safe width approach
                    constraints: BoxConstraints(maxWidth: 400.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security,
                          size: 60.r,
                          color: Colors.indigo.shade700,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'SÃ©curiser le compte',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Veuillez changer votre code par dÃ©faut',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        TextFormField(
                          controller: _newCodeController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Nouveau code',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.indigo,
                              size: 24.r,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Colors.indigo,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        TextFormField(
                          controller: _confirmCodeController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le code',
                            prefixIcon: Icon(
                              Icons.lock_reset,
                              color: Colors.indigo,
                              size: 24.r,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Colors.indigo,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),

                        _loading
                            ? const CircularProgressIndicator(
                                color: Colors.indigo,
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 50.h,
                                child: ElevatedButton(
                                  onPressed: _changeCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Confirmer',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper for width constraint if needed, or just use BoxConstraints directly.
  double constraints_box_width_check(double width) {
    return width;
  }
}
