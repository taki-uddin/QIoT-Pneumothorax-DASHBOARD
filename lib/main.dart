import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pneumothoraxdashboard/firebase_options.dart';
import 'package:pneumothoraxdashboard/helpers/session_storage_helpers.dart';
import 'package:pneumothoraxdashboard/routes/web_router_provider.dart';
import 'package:pneumothoraxdashboard/routes/web_routes.dart';
import 'package:pneumothoraxdashboard/screens/dashboard_screen/dashboard_screen.dart';
import 'package:pneumothoraxdashboard/screens/authentication_screen/signin_screen.dart';
import 'package:pneumothoraxdashboard/services/analytics_service.dart';
import 'package:pneumothoraxdashboard/services/push_notification_service.dart';
import 'package:pneumothoraxdashboard/services/token_refresh_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late bool _loginState;
String deviceType = 'web';
final Logger logger = Logger();

Future _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  if (message.notification != null) {
    logger.d('Message received in the background!');
  }
}

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
            child: const Text("Ok"))
      ],
    ),
  );
}

void main() async {
  final router = FluroRouter();

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    logger.d("Error initializing Firebase: $e");
  }

  PushNotificationService.init();
  await AnalyticsService.initialize();
  await PushNotificationService.localNotificationInit();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  PushNotificationService.onNotificationTapBackground();
  PushNotificationService.onNotificationTapForeground();
  PushNotificationService.onNotificationTerminatedState();

  try {
    String? loginState = await SessionStorageHelpers.getStorage('loginState');
    _loginState = loginState != null && loginState == 'true';
  } catch (e) {
    logger.d("Error getting login state: $e");
    _loginState = false;
  }

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

    _tokenRefreshService.startTokenRefreshTimer(); // Optional refresh token
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
      title: 'QIoT Pneumothorax Dashboard',
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
