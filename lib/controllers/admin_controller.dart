import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/users/commercant.dart';
import 'storage_service.dart';

class AdminController {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Optional: Admin client for operations requiring the service_role key (like creating users)
  /// WARNING: Use this only if the SUPABASE_SERVICE_ROLE_KEY is set in .env.
  /// Never expose this key in a production client-side app.
  SupabaseClient? get _adminClient {
    final serviceKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
    if (serviceKey == null || serviceKey.isEmpty) return null;
    return SupabaseClient(dotenv.env['SUPABASE_URL']!, serviceKey);
  }

  // ─── Merchants ──────────────────────────────────────────────────────────────

  Future<bool> createMerchant({
    required String email,
    required String password,
    String? fullname,
    String? telephone,
    String? nationalityId,
    String? nationalityCardFrontUrl,
    String? nationalityCardBackUrl,
  }) async {
    try {
      final adminClient = _adminClient;
      User? user;

      final metadata = {
        'role': 'commercant',
        'fullname': fullname ?? '',
        'telephone': telephone ?? '',
        'nationality_id': nationalityId ?? '',
        'nationality_card_front_url': nationalityCardFrontUrl ?? '',
        'nationality_card_back_url': nationalityCardBackUrl ?? '',
      };

      if (adminClient != null) {
        // Use Admin API to create user with metadata
        final resp = await adminClient.auth.admin.createUser(
          AdminUserAttributes(
            email: email,
            password: password,
            emailConfirm: true,
            userMetadata: metadata,
          ),
        );
        user = resp.user;
      } else {
        // Fallback to standard signUp
        final response = await _supabase.auth.signUp(
          email: email,
          password: password,
          data: metadata,
        );
        user = response.user;
      }

      if (user == null) return false;

      return true;
    } catch (e) {
      print('Error creating merchant: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getMerchantsStream() {
    return _supabase.from('commercants').stream(primaryKey: ['id']);
  }

  Future<void> updateMerchantEmail(String uid, String newEmail) async {
    await _supabase
        .from('commercants')
        .update({'email': newEmail})
        .eq('id', uid);
  }

  Future<void> deleteMerchant(String uid) async {
    // In Supabase, cascading deletes should be handled via database constraints
    await _supabase.from('commercants').delete().eq('id', uid);
    await _supabase.from('shops').delete().eq('merchant_id', uid);
  }

  // ─── Categories ─────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getCategoriesStream() {
    return _supabase.from('categories').stream(primaryKey: ['id']);
  }

  Future<void> createCategory(
    String name,
    IconData icon, {
    File? imageFile,
  }) async {
    String? imageUrl;

    if (imageFile != null) {
      imageUrl = await StorageService.instance.uploadImage(
        bucket: 'categories',
        file: imageFile,
        folder: 'icons',
      );
    }

    await _supabase.from('categories').insert({
      'name': name,
      'label_key': name.toLowerCase().replaceAll(' ', '_'),
      'icon_code_point': icon.codePoint,
      'icon_font_family': icon.fontFamily ?? 'MaterialIcons',
      'image_url': imageUrl,
    });
  }

  Future<void> updateCategory(
    String id,
    String name,
    IconData icon, {
    File? imageFile,
  }) async {
    Map<String, dynamic> data = {
      'name': name,
      'label_key': name.toLowerCase().replaceAll(' ', '_'),
      'icon_code_point': icon.codePoint,
      'icon_font_family': icon.fontFamily ?? 'MaterialIcons',
    };

    if (imageFile != null) {
      final imageUrl = await StorageService.instance.uploadImage(
        bucket: 'categories',
        file: imageFile,
        folder: 'icons',
      );
      if (imageUrl != null) {
        data['image_url'] = imageUrl;
      }
    }

    await _supabase.from('categories').update(data).eq('id', id);
  }

  Future<void> deleteCategory(String id) async {
    await _supabase.from('categories').delete().eq('id', id);
  }
}
