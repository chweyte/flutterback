import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Uploads a file to a specific bucket and returns the public URL.
  Future<String?> uploadImage({
    required String bucket,
    required File file,
    String? folder,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
      final path = folder != null ? '$folder/$fileName' : fileName;

      await _supabase.storage.from(bucket).upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('=== ERROR UPLOADING IMAGE === : $e');
      return null;
    }
  }

  /// Deletes a file from a bucket using its public URL.
  Future<void> deleteImage(String publicUrl) async {
    try {
      // Extract path from public URL
      // URL format: https://[project_id].supabase.co/storage/v1/object/public/[bucket]/[path]
      final uri = Uri.parse(publicUrl);
      final segments = uri.pathSegments;
      if (segments.length < 5) return;

      final bucket = segments[segments.length - 2];
      final path = segments.last;

      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      print('=== ERROR DELETING IMAGE === : $e');
    }
  }
}
