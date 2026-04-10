import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
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
        SnackBar(content: Text('Les codes ne correspondent pas'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _loading = true);
    await _auth.changerCodeCommercant(widget.commercantId, _newCodeController.text.trim());
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => CommercantHome()));
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
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                  child: Container(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.security, size: 60, color: Colors.indigo.shade700),
                        SizedBox(height: 16),
                        Text(
                          'Sécuriser le compte',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Veuillez changer votre code par défaut',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 32),
                        
                        TextFormField(
                          controller: _newCodeController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Nouveau code',
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.indigo),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.indigo, width: 2),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _confirmCodeController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le code',
                            prefixIcon: Icon(Icons.lock_reset, color: Colors.indigo),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.indigo, width: 2),
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        
                        _loading
                            ? CircularProgressIndicator(color: Colors.indigo)
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _changeCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Confirmer',
                                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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
}