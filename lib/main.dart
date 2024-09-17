import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pneumothoraxdashboard/helpers/session_storage_helpers.dart';
import 'package:pneumothoraxdashboard/routes/web_router_provider.dart';
import 'package:pneumothoraxdashboard/routes/web_routes.dart';
import 'package:pneumothoraxdashboard/screens/dashboard_screen.dart';
import 'package:pneumothoraxdashboard/screens/signin_screen.dart';
import 'package:pneumothoraxdashboard/services/push_notification_service.dart';
import 'package:pneumothoraxdashboard/services/token_refresh_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late bool _loginState;
String deviceType = 'web';

// to handle notification on foreground on web platform
void showNotification({required String title, required String body}) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Ok"))
      ],
    ),
  );
}

void main() async {
  final router = FluroRouter();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PushNotificationService.init();
  // Check login state from session storage
  String? loginState = await SessionStorageHelpers.getStorage('loginState');
  _loginState = loginState != null && loginState == 'true';
  defineRoutes(router);

  runApp(
    WebRouterProvider(
      router: router,
      child: Main(router: router),
    ),
  );
}

class Main extends StatefulWidget {
  final FluroRouter router;
  const Main({super.key, required this.router});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  late TokenRefreshService _tokenRefreshService;

  @override
  void initState() {
    super.initState();
    _tokenRefreshService = TokenRefreshService(); // Initialize the service here
    _initializeTokenRefreshService();
  }

  Future<void> _initializeTokenRefreshService() async {
    // Initialize the TokenRefreshService
    await Future.delayed(const Duration(seconds: 2)); // Optional delay
    _tokenRefreshService.initialize(null, deviceType);
  }

  @override
  void dispose() {
    _tokenRefreshService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QIoT Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey,
      onGenerateRoute: widget.router.generator,
      home: initialNavigation(),
    );
  }

  Widget initialNavigation() {
    return _loginState
        ? WebRouterProvider(
            router: widget.router,
            child: DashboardScreen(
              router: widget.router,
            ),
          )
        : WebRouterProvider(
            router: widget.router,
            child: const SigninScreen(),
          );
  }
}
