import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../controllers/category_service.dart';
import '../../../models/commerce/category_model.dart';
import '../../../controllers/storage_service.dart';

class CommercantProductsScreen extends StatefulWidget {
  const CommercantProductsScreen({super.key});

  @override
  State<CommercantProductsScreen> createState() => _CommercantProductsScreenState();
}

class _CommercantProductsScreenState extends State<CommercantProductsScreen> {
  final _supabase = Supabase.instance.client;
  String? _shopId;
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopAndProducts();
  }

  Future<void> _fetchShopAndProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return;
      
      final shopData = await _supabase.from('shops').select('id').eq('merchant_id', uid).maybeSingle();
      if (shopData != null) {
        _shopId = shopData['id'].toString();
        final prodData = await _supabase.from('products').select().eq('shop_id', _shopId!).order('created_at', ascending: false);
        if (mounted) {
          setState(() {
            _products = List<Map<String, dynamic>>.from(prodData);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _shopId = null;
            _products = [];
          });
        }
      }
    } catch (e) {
      print('=== ERROR FETCHING PRODUCTS === : $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      return const Center(child: Text('Non connecté'));
    }

    if (_isLoading && _shopId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_shopId == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: _fetchShopAndProducts,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 200),
              Center(
                child: Text(
                  'Veuillez d\'abord configurer votre boutique.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _fetchShopAndProducts,
        child: _products.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      'Aucun produit pour le moment.\nAppuyez sur + pour en ajouter.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: _products.length,
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final p = _products[index];
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: p['image_url'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                p['image_url'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                      title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p['price']} MAD', style: const TextStyle(color: Colors.orange)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                            onPressed: () => _showAddProductDialog(context, product: p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () async {
                              try {
                                await _supabase.from('products').delete().eq('id', p['id']);
                                if (p['image_url'] != null) {
                                  await StorageService.instance.deleteImage(p['image_url']);
                                }
                                _fetchShopAndProducts();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur lors de la suppression: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => _showAddProductDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, {Map<String, dynamic>? product}) {
    final nameCtrl = TextEditingController(text: product?['name'] ?? '');
    final priceCtrl = TextEditingController(text: product?['price'] ?? '');
    File? selectedImage;
    int? selectedCategoryId = product?['category_id'] as int?;
    bool isUploading = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(product != null ? 'Modifier le Produit' : 'Nouveau Produit'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() => selectedImage = File(picked.path));
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(selectedImage!, fit: BoxFit.cover),
                            )
                          : product?['image_url'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(product!['image_url'], fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, color: Colors.grey, size: 32),
                                    SizedBox(height: 8),
                                    Text('Ajouter/Modifier la photo', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nom du produit',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Prix (MAD)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: context.read<CategoryService>().all.map((c) {
                      return DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name ?? c.labelKey),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedCategoryId = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              if (!isUploading)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isUploading ? null : () async {
                  if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) return;
                  
                  setState(() => isUploading = true);
                  
                  try {
                    String? imageUrl;
                    if (selectedImage != null) {
                      imageUrl = await StorageService.instance.uploadImage(
                        bucket: 'products',
                        file: selectedImage!,
                        folder: 'images',
                      );
                    }

                    final doublePrice = double.tryParse(priceCtrl.text.trim()) ?? 0.0;

                    if (product == null) {
                      // Insert
                      await _supabase.from('products').insert({
                        'name': nameCtrl.text.trim(),
                        'price': priceCtrl.text.trim(),
                        'price_value': doublePrice.round(),
                        'shop_id': _shopId,
                        'category_id': selectedCategoryId,
                        if (imageUrl != null) 'image_url': imageUrl,
                      });
                    } else {
                      // Update
                      await _supabase.from('products').update({
                        'name': nameCtrl.text.trim(),
                        'price': priceCtrl.text.trim(),
                        'price_value': doublePrice.round(),
                        'category_id': selectedCategoryId,
                        if (imageUrl != null) 'image_url': imageUrl,
                      }).eq('id', product['id']);

                      // Delete old image if a new one was successfully uploaded
                      if (imageUrl != null && product['image_url'] != null) {
                        await StorageService.instance.deleteImage(product['image_url']);
                      }
                    }
                    
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(product != null ? 'Produit modifié avec succès' : 'Produit ajouté avec succès')),
                      );
                    }
                    _fetchShopAndProducts();
                  } catch (e) {
                    print('=== ERROR ADDING/EDITING PRODUCT === : $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors de l\'enregistrement: $e')),
                      );
                      setState(() => isUploading = false);
                    }
                  }
                },
                child: isUploading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(product != null ? 'Enregistrer' : 'Ajouter', style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }
}
