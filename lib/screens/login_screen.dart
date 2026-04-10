import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'admin/admin_home.dart';
import 'commercant/change_password_screen.dart';
import 'commercant/commercant_home.dart';
import 'client/signup_screen.dart';
import 'client/client_home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  String _selectedRole = 'client';
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (_selectedRole == 'admin') {
      String? role = await _auth.loginAdmin(email, password);
      if (role != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => AdminHome()));
      } else {
        _showError('Email ou code incorrect');
      }
    } else if (_selectedRole == 'commercant') {
      Map<String, dynamic>? result = await _auth.loginCommercant(email, password);
      if (result != null) {
        if (result['premiereConnexion'] == true) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => ChangePasswordScreen(commercantId: result['id'])));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => CommercantHome()));
        }
      } else {
        _showError('Email ou code incorrect');
      }
    } else {
      String? uid = await _auth.loginClient(email, password);
      if (uid != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => ClientHome()));
      } else {
        _showError('Email ou mot de passe incorrect');
      }
    }
    setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red));
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
                    width: 400, // Limite la largeur sur les grands écrans
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 60, color: Colors.indigo.shade700),
                        SizedBox(height: 16),
                        Text(
                          'Bienvenue',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Connectez-vous à votre compte',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 32),
                        
                        // Sélection du rôle
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRole,
                              isExpanded: true,
                              icon: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Icon(Icons.arrow_drop_down, color: Colors.indigo),
                              ),
                              items: [
                                DropdownMenuItem(value: 'admin', child: Padding(padding: EdgeInsets.only(left: 16), child: Text('Administrateur'))),
                                DropdownMenuItem(value: 'commercant', child: Padding(padding: EdgeInsets.only(left: 16), child: Text('Commerçant'))),
                                DropdownMenuItem(value: 'client', child: Padding(padding: EdgeInsets.only(left: 16), child: Text('Client'))),
                              ],
                              onChanged: (val) => setState(() => _selectedRole = val!),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        // Champ Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Adresse Email',
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.indigo),
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
                        
                        // Champ Mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe / Code',
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
                        SizedBox(height: 32),
                        
                        // Bouton Connexion
                        _loading
                            ? CircularProgressIndicator(color: Colors.indigo)
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Se connecter',
                                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                        
                        SizedBox(height: 24),
                        if (_selectedRole == 'client')
                          TextButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => SignupScreen())),
                            child: RichText(
                              text: TextSpan(
                                text: "Pas encore de compte ? ",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                                children: [
                                  TextSpan(
                                    text: "S'inscrire",
                                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                                  ),
                                ],
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