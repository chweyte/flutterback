import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../models/users/commercant.dart';

class AdminController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Merchants ──────────────────────────────────────────────────────────────

  Future<bool> createMerchant({
    required String email,
    required String password,
  }) async {
    try {
      final secondaryApp = await Firebase.initializeApp(
        name: 'Secondary',
        options: Firebase.app().options,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      UserCredential userCredential =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      await secondaryAuth.signOut();
      await secondaryApp.delete();

      final commercant = Commercant(
        id: uid,
        email: email,
        code: password,
        premiereConnexion: true,
      );

      await _db.collection('commercants').doc(uid).set(commercant.toMap());
      return true;
    } catch (e) {
      print('Error creating merchant: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getMerchantsStream() {
    return _db.collection('commercants').snapshots();
  }

  Future<void> updateMerchantEmail(String uid, String newEmail) async {
    await _db.collection('commercants').doc(uid).update({'email': newEmail});
  }

  Future<void> deleteMerchant(String uid) async {
    final batch = _db.batch();
    batch.delete(_db.collection('commercants').doc(uid));
    batch.delete(_db.collection('shops').doc(uid));
    await batch.commit();
  }

  // ─── Categories ─────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getCategoriesStream() {
    return _db.collection('categories').snapshots();
  }

  Future<void> createCategory(String name, IconData icon, {File? imageFile}) async {
    String? imageAssetPath;
    
    if (imageFile != null) {
      // Create a unique filename
      final fileName = 'cat_${name.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';
      
      // Save to assets folder
      const assetsDir = 'c:\\Users\\kaber\\Downloads\\flutterback\\assets';
      final destination = p.join(assetsDir, fileName);
      
      try {
        await imageFile.copy(destination);
        imageAssetPath = 'assets/$fileName';
      } catch (e) {
        print('Error saving image to assets: $e');
      }
    }

    await _db.collection('categories').add({
      'name': name,
      'labelKey': name.toLowerCase().replaceAll(' ', '_'),
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily ?? 'MaterialIcons',
      'imageAsset': imageAssetPath,
    });
  }

  Future<void> updateCategory(String id, String name, IconData icon, {File? imageFile}) async {
    Map<String, dynamic> data = {
      'name': name,
      'labelKey': name.toLowerCase().replaceAll(' ', '_'),
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily ?? 'MaterialIcons',
    };

    if (imageFile != null) {
      final fileName = 'cat_${name.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';
      const assetsDir = 'c:\\Users\\kaber\\Downloads\\flutterback\\assets';
      final destination = p.join(assetsDir, fileName);
      
      try {
        await imageFile.copy(destination);
        data['imageAsset'] = 'assets/$fileName';
      } catch (e) {
        print('Error saving image to assets: $e');
      }
    }

    await _db.collection('categories').doc(id).update(data);
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }
}
