import 'dart:async';
import 'dart:html' as html;
import 'package:pneumothoraxdashboard/helpers/session_storage_helpers.dart';
import 'package:pneumothoraxdashboard/api/authentication.dart';

class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  Timer? _timer;
  String? _deviceToken;
  String? _deviceType;

  factory TokenRefreshService() {
    return _instance;
  }

  TokenRefreshService._internal();

  void initialize(String? deviceToken, String deviceType) {
    _deviceToken = deviceToken;
    _deviceType = deviceType;
    _startTokenRefreshTimer();
    _setupVisibilityChangeListener();
  }

  void _startTokenRefreshTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 45), (timer) async {
      print('Token refresh timer triggered at ${DateTime.now()}');
      await _refreshToken();
    });
  }

  Future<void> _refreshToken() async {
    if (_deviceType == null) {
      print('Token refresh skipped: insufficient data.');
      return;
    }
    String? accessToken = await SessionStorageHelpers.getStorage('accessToken');
    String? refreshToken =
        await SessionStorageHelpers.getStorage('refreshToken');
    try {
      final response = await Authentication().refreshToken(
        accessToken!,
        refreshToken!,
        null,
        _deviceType!,
      );
      final jsonResponse = response;
      if (jsonResponse['data']['status'] == 200) {
        final newAccessToken = jsonResponse['data']['accessToken'];
        final newRefreshToken = jsonResponse['data']['refreshToken'];
        _updateTokens(newAccessToken, newRefreshToken);
      }
    } catch (e) {
      print('Failed to refresh token: $e');
    }
  }

  void _updateTokens(String newAccessToken, String newRefreshToken) {
    SessionStorageHelpers.setStorage('accessToken', newAccessToken);
    SessionStorageHelpers.setStorage('refreshToken', newRefreshToken);
  }

  void _setupVisibilityChangeListener() {
    html.document.onVisibilityChange.listen((event) {
      if (html.document.visibilityState == 'visible') {
        print('App is visible again');
        _startTokenRefreshTimer(); // Restart timer when app becomes visible
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
