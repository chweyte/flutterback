import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';
import 'screens/landing_screen.dart';
import 'screens/client/client_home.dart';
import 'screens/admin/admin_home.dart';
import 'screens/commercant/commercant_home.dart';
import 'core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      child: const MyApp(),
    ),
  );
}

// ── Global scroll behavior ────────────────────────────────────────────────────
// Appliqué à toute l'app : supprime l'effet élastique/rebond sur tous les
// widgets scrollables (ListView, CustomScrollView, SingleChildScrollView…)
// sans avoir à répéter physics: sur chaque widget.
// Étend MaterialScrollBehavior (pas ScrollBehavior) pour garder toute la
// configuration des gestes tactiles Android. On remplace juste la physique
// pour supprimer le rebond élastique et l'indicateur de surscroll.
class _NoOverscrollBehavior extends MaterialScrollBehavior {
  const _NoOverscrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return ToastificationWrapper(
          child: MaterialApp(
            title: 'app_name'.tr(),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            // Fix global : ClampingScrollPhysics pour toute l'application
            scrollBehavior: const _NoOverscrollBehavior(),
            home: const AuthWrapper(),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, roleSnapshot) {
        if (roleSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = roleSnapshot.data;

        if (role == 'admin') {
          return AdminHome();
        }

        if (role == 'commercant') {
          return CommercantHome();
        }

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasData && snapshot.data!.emailVerified) {
              return const ClientHome();
            }
            return LandingScreen();
          },
        );
      },
    );
  }
}
