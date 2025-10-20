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
    String? accessToken = await SessionStorageHelpers.getStorage('accessToken');
    String? refreshToken =
        await SessionStorageHelpers.getStorage('refreshToken');

    // Only consider user logged in if we have all required tokens
    _loginState =
        loginState == 'true' && accessToken != null && refreshToken != null;

    if (_loginState) {
      logger.d('User is logged in - tokens found');
    } else {
      logger.d('User is not logged in - clearing any partial state');
      // Clear any partial authentication state
      await SessionStorageHelpers.clearStorage();
    }
  } catch (e) {
    logger.d("Error getting login state: $e");
    _loginState = false;
    // Clear storage on error to ensure clean state
    await SessionStorageHelpers.clearStorage();
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
    // Only initialize token refresh service if user is logged in
    if (!_loginState) {
      logger.d('Token refresh service not initialized: user not logged in');
      return;
    }

    try {
      // Get FCM device token
      String? deviceToken = await PushNotificationService.getFCMToken();

      if (deviceToken != null) {
        logger.d('Initializing token refresh service with device token');
        _tokenRefreshService.initialize(deviceToken, deviceType);
        _tokenRefreshService.startTokenRefreshTimer();
      } else {
        logger.d(
            'Token refresh service not initialized: no device token available');
      }
    } catch (e) {
      logger.d('Error initializing token refresh service: $e');
    }
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
