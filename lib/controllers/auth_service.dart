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

  // Generic Sign In
  Future<User?> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  // Get User Role
  Future<String?> getUserRole(String uid) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', uid)
          .maybeSingle();
      return data?['role'];
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
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

  // --- GOOGLE OAUTH ---
  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );
    } catch (e) {
      print('=== ERREUR GOOGLE SIGNIN === : $e');
      rethrow;
    }
  }

  // --- OTP SIGN-IN (Email) ---
  Future<void> sendOtp(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );
    } catch (e) {
      print('=== ERREUR ENVOI OTP === : $e');
      rethrow;
    }
  }

  Future<AuthResponse> verifyOtp(String email, String token) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup, // Use OtpType.magiclink for login if needed
      );
      return response;
    } catch (e) {
      print('=== ERREUR VERIFICATION OTP === : $e');
      rethrow;
    }
  }


  // Changer le code (mot de passe) du commerÃ§ant
  Future<void> changerCodeCommercant(String id, String nouveauCode) async {
    // Mettre Ã  jour le mot de passe dans Supabase Auth
    await _supabase.auth.updateUser(UserAttributes(password: nouveauCode));
    
    // Marquer la premiÃ¨re connexion comme effectuÃ©e
    await _supabase.from('commercants').update({
      'premiere_connexion': false,
    }).eq('id', id);
  }

  // Inscription Client
  Future<String?> signupClient({
    required String email,
    required String password,
    required String fullname,
    String? telephone,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': 'client',
          'fullname': fullname,
          'telephone': telephone ?? '',
        },
      );
      
      final user = response.user;
      if (user == null) return null;

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

      // if (user.emailConfirmedAt == null) {
      //   throw const AuthException(
      //     'Veuillez vérifier votre email via le lien envoyé avant de vous connecter.',
      //   );
      // }

      // S'assurer que le profil existe (managed by DB trigger now, but good to have)
      await ensureClientProfileExists(user.id, email, user.userMetadata?['fullname'] ?? '');

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
  Future<void> ensureClientProfileExists(String uid, String email, String fullname) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (response == null) {
      // Insert in profiles (trigger usually does this, but for legacy users)
      await _supabase.from('profiles').upsert({
        'id': uid,
        'email': email,
        'fullname': fullname,
        'role': 'client',
      });
      
      // Insert in clients
      await _supabase.from('clients').upsert({
        'id': uid,
      });
    }
  }
}