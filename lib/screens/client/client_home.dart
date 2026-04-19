import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/route_transitions.dart';
import '../landing_screen.dart';

class ClientHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Espace Client',
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
                color: const Color(0xFF007AFF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 80, color: Color(0xFF007AFF)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bienvenue Client !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ],
        ),
      ),
    );
  }
}