import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/route_transitions.dart';
import '../landing_screen.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Espace Administrateur',
           style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1E293B)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, SlidePageRoute(page: LandingScreen()));
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings, size: 80, color: Colors.blue),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bienvenue Administrateur !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ],
        ),
      ),
    );
  }
}