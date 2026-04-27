import 'package:flutter/material.dart';
import '../../controllers/auth_service.dart';
import '../../controllers/route_transitions.dart';
import '../landing_screen.dart';

class CommercantHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Espace CommerÃ§ant',
           style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1E293B)),
            onPressed: () async {
              await AuthService().logout();
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
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.store, size: 80, color: Colors.orange),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bienvenue CommerÃ§ant !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ],
        ),
      ),
    );
  }
}
