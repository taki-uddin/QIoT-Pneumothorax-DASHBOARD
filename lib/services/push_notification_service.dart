import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pneumothoraxdashboard/main.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    getFCMToken();
  }

// get the fcm device token
  static Future getFCMToken({int maxRetires = 3}) async {
    String? token;
    try {
      token = await _firebaseMessaging.getToken(
          vapidKey:
              'BHUmYLbdwedDQjN4btEurN4SBwTLJYNwcZy3WKA2DL3UMu7fhc0Pe23S-zzubOvQkt_FdmfWcyk2u1WA38-6C3s');
      print('for web device token: $token');
      return token;
    } catch (e) {
      print('failed to get device token');
      if (maxRetires > 0) {
        print('try after 10 sec');
        await Future.delayed(const Duration(seconds: 10));
        return getFCMToken(maxRetires: maxRetires - 1);
      } else {
        return null;
      }
    }
  }

  static Future localNotificationInit() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Check if _flutterLocalNotificationsPlugin is not null
    if (_flutterLocalNotificationsPlugin != null) {
      // request notification permissions for android 13 or above
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap,
      );
    } else {
      // Handle the case where _flutterLocalNotificationsPlugin is null
      print('Error: _flutterLocalNotificationsPlugin is null');
    }
  }

  // on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    Future.delayed(const Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed(
        "/notification",
        arguments: notificationResponse,
      );
    });
  }

  static void onNotificationTapBackground() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Message received in the background!');
        navigatorKey.currentState!.pushNamed(
          "/notification",
          arguments: message,
        );
      }
    });
  }

  static void onNotificationTapForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String payloadData = jsonEncode(message.data);
      print('Message received in the foreground!');
      if (message.notification != null) {
        if (kIsWeb) {
          showNotification(
            title: message.notification!.title!,
            body: message.notification!.body!,
          );
        } else {
          PushNotificationService.showSimpleNotification(
            title: message.notification!.title,
            body: message.notification!.body,
            payload: payloadData,
          );
        }
      }
    });
  }

  static void onNotificationTerminatedState() async {
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('Message received in terminated state!');
      Future.delayed(const Duration(seconds: 1), () {
        navigatorKey.currentState!.pushNamed(
          "/notification",
          arguments: initialMessage,
        );
      });
    }
  }

  // show a simple notification
  static Future showSimpleNotification({
    required String? title,
    required String? body,
    required String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
