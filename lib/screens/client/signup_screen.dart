import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'client_home.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _loading = false;

  Future<void> _signup() async {
    setState(() => _loading = true);
    try {
      String? uid = await _auth.signupClient(
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );
      if (uid != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => ClientHome()));
      }
    } catch (e) {
      // Nettoyer un peu le préfixe de l'erreur Firebase pour une meilleure lecture (optionnel)
      String errorMsg = e.toString();
      if (errorMsg.contains(']')) {
        errorMsg = errorMsg.split(']').last.trim();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $errorMsg'), backgroundColor: Colors.red, duration: Duration(seconds: 5)));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container( // Ajout du gradient d'arrière-plan
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
                    width: 400, // Limite la largeur sur écrans larges
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_outlined, size: 60, color: Colors.indigo.shade700),
                        SizedBox(height: 16),
                        Text(
                          'Créer un compte',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Rejoignez-nous en tant que client',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 32),
                        
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
                        
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Numéro de téléphone',
                            prefixIcon: Icon(Icons.phone_outlined, color: Colors.indigo),
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
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
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
                        
                        _loading
                            ? CircularProgressIndicator(color: Colors.indigo)
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _signup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    "S'inscrire",
                                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              
                        SizedBox(height: 24),
                        TextButton(
                          onPressed: () => Navigator.pop(context), // Retour à la page de connexion
                          child: RichText(
                            text: TextSpan(
                              text: "Vous avez déjà un compte ? ",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                              children: [
                                TextSpan(
                                  text: "Se connecter",
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