import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../controllers/admin_controller.dart';
import 'package:toastification/toastification.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  void _showToast(BuildContext context, String msg, ToastificationType type) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flatColored,
      title: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }

  // All available icons the admin can pick from
  static const List<(String label, IconData icon)> _iconOptions = [
    ('Restaurant', Icons.restaurant_rounded),
    ('Grocery', Icons.local_grocery_store_rounded),
    ('Pharmacy', Icons.local_pharmacy_rounded),
    ('Coffee', Icons.coffee_rounded),
    ('Bakery', Icons.bakery_dining_rounded),
    ('Electronics', Icons.devices_rounded),
    ('Clothing', Icons.checkroom_rounded),
    ('Sport', Icons.sports_soccer_rounded),
    ('Beauty', Icons.spa_rounded),
    ('Books', Icons.menu_book_rounded),
    ('Pets', Icons.pets_rounded),
    ('Other', Icons.category_rounded),
  ];

  void _showCategorySheet(
    BuildContext context, {
    String? id,
    String? initialName,
    IconData? initialIcon,
    String? initialImageAsset,
  }) {
    final nameController = TextEditingController(text: initialName ?? '');
    IconData selectedIcon = initialIcon ?? _iconOptions.first.$2;
    File? selectedImage;
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  id != null ? 'Edit Category' : 'New Category',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Photo picker
                const Text(
                  'Category Photo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setSheet(() => selectedImage = File(picked.path));
                    }
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.file(selectedImage!, fit: BoxFit.cover),
                          )
                        : (initialImageAsset != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.asset(initialImageAsset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder()),
                              )
                            : _buildPlaceholder()),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'e.g. Grocery',
                    hintStyle: const TextStyle(color: AppColors.textLight),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Icon',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                // Icon picker grid
                SizedBox(
                  height: 150,
                  child: GridView.count(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: _iconOptions.map((opt) {
                      final isSelected = selectedIcon.codePoint == opt.$2.codePoint;
                      return GestureDetector(
                        onTap: () => setSheet(() => selectedIcon = opt.$2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            opt.$2,
                            size: 22,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        _showToast(context, 'Name is required.', ToastificationType.warning);
                        return;
                      }
                      try {
                        if (id != null) {
                          await AdminController().updateCategory(
                            id, 
                            name, 
                            selectedIcon,
                            imageFile: selectedImage,
                          );
                        } else {
                          await AdminController().createCategory(
                            name, 
                            selectedIcon,
                            imageFile: selectedImage,
                          );
                        }
                        Navigator.pop(ctx);
                        if (context.mounted) {
                          _showToast(
                            context,
                            id != null ? 'Category updated.' : 'Category created.',
                            ToastificationType.success,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          _showToast(context, 'Operation failed.', ToastificationType.error);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      id != null ? 'Save Changes' : 'Create Category',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Category',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Delete "$name"? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await AdminController().deleteCategory(id);
        if (context.mounted) {
          _showToast(context, 'Category deleted.', ToastificationType.success);
        }
      } catch (e) {
        if (context.mounted) {
          _showToast(context, 'Failed to delete.', ToastificationType.error);
        }
      }
    }
  }

  Widget _buildPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, color: AppColors.textLight, size: 32),
        SizedBox(height: 8),
        Text(
          'Tap to choose a photo',
          style: TextStyle(color: AppColors.textLight, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: AdminController().getCategoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  const Text(
                    'No categories yet',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap + to add your first category',
                    style: TextStyle(fontSize: 13, color: AppColors.textLight),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final data = categories[i];
              final id = data['id'].toString();
              final name = data['name'] ?? data['label_key'] ?? '—';
              final iconData = IconData(
                data['icon_code_point'] ?? Icons.category_rounded.codePoint,
                fontFamily: data['icon_font_family'] ?? 'MaterialIcons',
              );
              final imageAsset = data['image_asset'] as String?;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: imageAsset != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              imageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Try fallback for local preview
                                return Icon(iconData, color: AppColors.primary, size: 22);
                              },
                            ),
                          )
                        : Icon(iconData, color: AppColors.primary, size: 22),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
                        onPressed: () => _showCategorySheet(
                          context,
                          id: id,
                          initialName: name,
                          initialIcon: iconData,
                          initialImageAsset: imageAsset,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accent, size: 20),
                        onPressed: () => _confirmDelete(context, id, name),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategorySheet(context),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
