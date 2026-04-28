import 'package:flutter/material.dart';
import '../../controllers/auth_service.dart';
import '../../controllers/route_transitions.dart';
import '../landing_screen.dart';

class CommercantHome extends StatefulWidget {
  const CommercantHome({super.key});

  @override
  State<CommercantHome> createState() => _CommercantHomeState();
}

class _CommercantHomeState extends State<CommercantHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardPlaceholder(),
    _ProductsPlaceholder(),
    _ShopPlaceholder(),
    _ProfilePlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Espace Commerçant',
           style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1E293B)),
            onPressed: () async {
              await AuthService().logout();
              if (mounted) {
                Navigator.pushReplacement(context, SlidePageRoute(page: const LandingScreen()));
              }
            },
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Tableau',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Boutique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _DashboardPlaceholder extends StatelessWidget {
  const _DashboardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
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
            'Bienvenue Commerçant !',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Voici votre tableau de bord',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ProductsPlaceholder extends StatelessWidget {
  const _ProductsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Mes Produits', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}

class _ShopPlaceholder extends StatelessWidget {
  const _ShopPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Ma Boutique', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Mon Profil', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}
