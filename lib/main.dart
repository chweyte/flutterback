import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';
import 'views/landing_screen.dart';
import 'views/login_screen.dart';
import 'views/client/client_home.dart';
import 'views/admin/admin_home.dart';
import 'views/commercant/commercant_home.dart';
import 'core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import 'controllers/product_service.dart';
import 'controllers/shop_service.dart';
import 'controllers/category_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenLanding = prefs.getBool('has_seen_landing') ?? false;

  // Initialisation des services connectés à Firestore
  ProductService.instance.initialize();
  ShopService.instance.initialize();
  CategoryService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ProductService.instance),
        ChangeNotifierProvider.value(value: ShopService.instance),
        ChangeNotifierProvider.value(value: CategoryService.instance),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('fr'), Locale('ar'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('fr'),
        child: MyApp(hasSeenLanding: hasSeenLanding),
      ),
    ),
  );
}

// Global scroll behavior
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
  ) => child;
}

class MyApp extends StatelessWidget {
  final bool hasSeenLanding;
  const MyApp({super.key, required this.hasSeenLanding});

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
            scrollBehavior: const _NoOverscrollBehavior(),
            home: AuthWrapper(initialHasSeenLanding: hasSeenLanding),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final bool initialHasSeenLanding;
  const AuthWrapper({super.key, required this.initialHasSeenLanding});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<String?>? _userRoleFuture;
  User? _lastUser;
  late Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  Future<String?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, authSnapshot) {
        // If we don't have auth data yet, we default to the most likely screen
        // rather than showing a jarring loading spinner.
        final user = authSnapshot.data;
        
        if (user == null) {
          // If the stream is waiting and we have no data, we still show Login/Landing
          // to avoid a black screen or spinner flicker.
          if (!widget.initialHasSeenLanding) {
            return const LandingScreen();
          }
          return const LoginScreen();
        }

        // User is authenticated, now check role-based routing
        if (user != _lastUser) {
          _lastUser = user;
          _userRoleFuture = _getUserRole();
        }

        return FutureBuilder<String?>(
          future: _userRoleFuture,
          builder: (context, roleSnapshot) {
            // Even for roles, we avoid a full-page spinner if possible.
            // But role check is usually necessary before showing Home.
            if (roleSnapshot.connectionState == ConnectionState.waiting && !roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;
            if (role == 'admin') return const AdminHome();
            if (role == 'commercant') return const CommercantHome();

            // Client verification check
            if (user.emailVerified) {
              return const ClientHome();
            }
            
            // If not verified, stay on Login (which handles verification states)
            // instead of jumping back to Landing.
            return const LoginScreen();
          },
        );
      },
    );
  }
}



