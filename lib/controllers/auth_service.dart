import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/users/commercant.dart';
import 'merchant_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // DÃƒÂ©connexion globale
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();
  }

  // Connexion Admin
  Future<String?> loginAdmin(String email, String password) async {
    if (email == 'admin@gmail.com' && password == 'adminadmin') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'admin');
      return 'admin';
    }
    return null;
  }

  // Connexion CommerÃƒÂ§ant
  Future<Commercant?> loginCommercant(String email, String password) async {
    try {
      QuerySnapshot query = await _db
          .collection('commercants')
          .where('email', isEqualTo: email)
          .where('code', isEqualTo: password)
          .get();

      if (query.docs.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'commercant');
        await prefs.setString('user_id', query.docs.first.id);
        
        // Charger la boutique du commerçant
        await MerchantService.instance.loadMerchantShop(query.docs.first.id);
        
        return Commercant.fromMap(query.docs.first.id, query.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('=== ERREUR LOGIN COMMERCANT === : $e');
      return null;
    }
  }

  // Changer le code du commerÃƒÂ§ant
  Future<void> changerCodeCommercant(String id, String nouveauCode) async {
    await _db.collection('commercants').doc(id).update({
      'code': nouveauCode,
      'premiereConnexion': false,
    });
  }

  // Inscription Client
  Future<String?> signupClient(String email, String telephone, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Envoi de l'email de vÃƒÂ©rification
      await result.user!.sendEmailVerification();

      return result.user!.uid;
    } catch (e) {
      print('=== ERREUR INSCRIPTION === : $e');
      throw e;
    }
  }

  // Connexion Client
  Future<String?> loginClient(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!result.user!.emailVerified) {
        throw FirebaseAuthException(
          code: 'unverified-email', 
          message: 'Veuillez vÃƒÂ©rifier votre email via le lien envoyÃƒÂ© avant de vous connecter.'
        );
      }

      // S'assurer que le profil Firestore existe
      await ensureClientProfileExists(result.user!.uid, email);

      return result.user!.uid;
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'unverified-email') {
        throw e;
      }
      return null;
    }
  }

  // RÃƒÂ©initialisation mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e;
    }
  }

  // CrÃƒÂ©ation du profil Firebase au moment de la vÃƒÂ©rification
  Future<void> ensureClientProfileExists(String uid, String email) async {
    var doc = await _db.collection('clients').doc(uid).get();
    if (!doc.exists) {
      await _db.collection('clients').doc(uid).set({
        'email': email,
        'telephone': '',
        'createdAt': DateTime.now(),
      });
    }
  }
}