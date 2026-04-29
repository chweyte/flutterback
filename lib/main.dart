import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'views/landing_screen.dart';
import 'views/login_screen.dart';
import 'views/client/client_home.dart';
import 'views/admin/admin_home.dart';
import 'views/commercant/commercant_home.dart';
import 'core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/auth_service.dart';

import 'package:provider/provider.dart';
import 'controllers/product_service.dart';
import 'controllers/shop_service.dart';
import 'controllers/category_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenLanding = prefs.getBool('has_seen_landing') ?? false;

  // Initialisation des services
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
  late Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = Supabase.instance.client.auth.onAuthStateChange;
  }

  Future<String?> _getUserRole(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('user_role');

    if (role == null) {
      // Fetch from database
      role = await AuthService().getUserRole(uid);
      if (role != null) {
        await prefs.setString('user_role', role);
      }
    }
    return role;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStream,
      builder: (context, authSnapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        final user = session?.user;

        if (user == null) {
          if (!widget.initialHasSeenLanding) {
            return const LandingScreen();
          }
          return const LoginScreen();
        }

        // User is authenticated, now check role-based routing
        if (user != _lastUser) {
          _lastUser = user;
          _userRoleFuture = _getUserRole(user.id);
        }

        return FutureBuilder<String?>(
          future: _userRoleFuture,
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting &&
                !roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;
            if (role == 'admin') return const AdminHome();
            if (role == 'commercant') return const CommercantHome();

            // Client verification check
            if (user.emailConfirmedAt != null) {
              return const ClientHome();
            }

            return const LoginScreen();
          },
        );
      },
    );
  }
}
