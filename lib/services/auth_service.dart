import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Connexion Admin
  Future<String?> loginAdmin(String email, String password) async {
    if (email == 'admin@gmail.com' && password == 'adminadmin') {
      return 'admin';
    }
    return null;
  }

  // Connexion Commerçant
  Future<Map<String, dynamic>?> loginCommercant(String email, String password) async {
    try {
      // Vérifier dans Firestore
      QuerySnapshot query = await _db
          .collection('commercants')
          .where('email', isEqualTo: email)
          .where('code', isEqualTo: password)
          .get();

      if (query.docs.isNotEmpty) {
        var data = query.docs.first.data() as Map<String, dynamic>;
        bool isFirstConnection = data.containsKey('premiereConnexion') ? data['premiereConnexion'] : true;
        
        return {
          'id': query.docs.first.id,
          'premiereConnexion': isFirstConnection,
        };
      }
      return null;
    } catch (e) {
      print('=== ERREUR LOGIN COMMERCANT === : $e');
      return null;
    }
  }

  // Changer le code du commerçant
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
      
      // Envoi de l'email de vérification
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
          message: 'Veuillez vérifier votre email via le lien envoyé avant de vous connecter.'
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

  // Réinitialisation mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e;
    }
  }

  // Création du profil Firebase au moment de la vérification
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