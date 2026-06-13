import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommercantShopScreen extends StatefulWidget {
  const CommercantShopScreen({super.key});

  @override
  State<CommercantShopScreen> createState() => _CommercantShopScreenState();
}

class _CommercantShopScreenState extends State<CommercantShopScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _shopData;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchShop();
  }

  Future<void> _fetchShop() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    
    final data = await _supabase.from('shops').select().eq('merchant_id', uid).maybeSingle();
    if (mounted) {
      setState(() {
        _shopData = data;
        if (data != null) {
          _nameCtrl.text = data['name'] ?? '';
          _descCtrl.text = data['description'] ?? '';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveShop() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;

    if (_shopData == null) {
      // Create new shop
      await _supabase.from('shops').insert({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'merchant_id': uid,
      });
    } else {
      // Update existing
      await _supabase.from('shops').update({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
      }).eq('id', _shopData!['id']);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boutique enregistrée avec succès')),
      );
      _fetchShop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuration de la boutique',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nom de la boutique',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveShop,
              child: const Text('Enregistrer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
