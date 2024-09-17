import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

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
}
