import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/users/commercant.dart';
import 'merchant_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Déconnexion globale
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _supabase.auth.signOut();
  }

  // Connexion Admin
  Future<String?> loginAdmin(String email, String password) async {
    try {
      // 1. Authentification via Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return null;

      // 2. Vérifier si l'utilisateur est bien dans la table 'profiles' ou 'admins'
      final profileData = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      if (profileData['role'] == 'admin') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'admin');
        return 'admin';
      } else {
        await _supabase.auth.signOut();
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
      // 1. Authentification via Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return null;

      // 2. Récupérer les infos dans la table 'commercants'
      final doc = await _supabase
          .from('commercants')
          .select()
          .eq('id', user.id)
          .single();

      if (doc != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'commercant');
        await prefs.setString('user_id', user.id);
        
        await MerchantService.instance.loadMerchantShop(user.id);
        
        return Commercant.fromMap(user.id, doc);
      } else {
        await _supabase.auth.signOut();
        return null;
      }
    } catch (e) {
      print('=== ERREUR LOGIN COMMERCANT === : $e');
      return null;
    }
  }

  // Changer le code du commerçant
  Future<void> changerCodeCommercant(String id, String nouveauCode) async {
    await _supabase.from('commercants').update({
      'code': nouveauCode,
      'premiere_connexion': false,
    }).eq('id', id);
  }

  // Inscription Client
  Future<String?> signupClient(String email, String telephone, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'telephone': telephone},
      );
      
      final user = response.user;
      if (user == null) return null;

      // Supabase handles email verification automatically if configured
      return user.id;
    } catch (e) {
      print('=== ERREUR INSCRIPTION === : $e');
      rethrow;
    }
  }

  // Connexion Client
  Future<String?> loginClient(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return null;

      if (user.emailConfirmedAt == null) {
        throw const AuthException(
          'Veuillez vérifier votre email via le lien envoyé avant de vous connecter.',
        );
      }

      // S'assurer que le profil existe
      await ensureClientProfileExists(user.id, email);

      return user.id;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      return null;
    }
  }

  // Réinitialisation mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Création du profil au moment de la vérification
  Future<void> ensureClientProfileExists(String uid, String email) async {
    final response = await _supabase
        .from('clients')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (response == null) {
      await _supabase.from('clients').insert({
        'id': uid,
        'email': email,
        'telephone': '',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Also ensure role is set in profiles
      await _supabase.from('profiles').upsert({
        'id': uid,
        'email': email,
        'role': 'client',
      });
    }
  }
}