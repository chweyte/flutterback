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
    try {
      // 1. Authentification via Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Vérifier si l'utilisateur est bien dans la collection 'admins'
      DocumentSnapshot adminDoc = await _db.collection('admins').doc(result.user!.uid).get();
      
      // Alternative : si l'admin est identifié par email dans Firestore
      if (!adminDoc.exists) {
        QuerySnapshot query = await _db
            .collection('admins')
            .where('email', isEqualTo: email)
            .get();
        if (query.docs.isNotEmpty) {
          adminDoc = query.docs.first;
        }
      }

      if (adminDoc.exists) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'admin');
        return 'admin';
      } else {
        await _auth.signOut();
        return null;
      }
    } catch (e) {
      print('=== ERREUR LOGIN ADMIN === : $e');
      return null;
    }
  }

  // Connexion Commerçant
  Future<Commercant?> loginCommercant(String email, String password) async {
    try {
      // 1. Authentification via Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Récupérer les infos dans Firestore
      DocumentSnapshot doc = await _db.collection('commercants').doc(result.user!.uid).get();

      if (doc.exists) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'commercant');
        await prefs.setString('user_id', doc.id);
        
        await MerchantService.instance.loadMerchantShop(doc.id);
        
        return Commercant.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        await _auth.signOut();
        return null;
      }
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