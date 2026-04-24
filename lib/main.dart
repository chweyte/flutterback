import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';
import 'screens/landing_screen.dart';
import 'screens/client/client_home.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize easy_localization before Firebase
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // Wrap app with EasyLocalization to enable multi-language + RTL support
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
            // Pass locale + delegates from easy_localization
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const AuthWrapper(),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  }
}
