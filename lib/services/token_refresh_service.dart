import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pneumothoraxdashboard/helpers/session_storage_helpers.dart';
import 'package:pneumothoraxdashboard/api/authentication.dart';
import 'package:pneumothoraxdashboard/main.dart';

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
    _timer = Timer.periodic(const Duration(minutes: 45), (timer) async {
      startTokenRefreshTimer();
    });
    _setupVisibilityChangeListener();
  }

  void startTokenRefreshTimer() async {
    _timer?.cancel();
    await _refreshToken();
  }

  Future<void> _refreshToken() async {
    if (_deviceType == null) {
      logger.d('Token refresh skipped: insufficient data.');
      return;
    }
    
    // Check if user is still logged in
    String? loginState = await SessionStorageHelpers.getStorage('loginState');
    if (loginState != 'true') {
      logger.d('Token refresh skipped: user not logged in');
      return;
    }
    
    String? accessToken = await SessionStorageHelpers.getStorage('accessToken');
    String? refreshToken =
        await SessionStorageHelpers.getStorage('refreshToken');
    
    // Check if tokens exist before proceeding
    if (accessToken == null || refreshToken == null) {
      logger.d('Token refresh skipped: accessToken or refreshToken is null');
      return;
    }
    
    try {
      final response = await Authentication().refreshToken(
        accessToken,
        refreshToken,
        _deviceToken,
        _deviceType!,
      );
      final jsonResponse = response;
      if (jsonResponse['data']['status'] == 200) {
        final newAccessToken = jsonResponse['data']['accessToken'];
        final newRefreshToken = jsonResponse['data']['refreshToken'];
        _updateTokens(newAccessToken, newRefreshToken);
        logger.d('Token refresh successful');
      } else {
        logger.d('Token refresh failed: ${jsonResponse['data']}');
        // If token refresh fails, log out the user
        await _handleTokenRefreshFailure();
      }
    } catch (e) {
      logger.d('Failed to refresh token: $e');
      // If token refresh fails, log out the user
      await _handleTokenRefreshFailure();
    }
  }

  void _updateTokens(String newAccessToken, String newRefreshToken) {
    SessionStorageHelpers.setStorage('accessToken', newAccessToken);
    SessionStorageHelpers.setStorage('refreshToken', newRefreshToken);
  }

  Future<void> _handleTokenRefreshFailure() async {
    logger.d('Handling token refresh failure - logging out user');
    // Clear stored tokens and login state
    await SessionStorageHelpers.clearStorage();
    // Navigate to login screen
    if (navigatorKey.currentContext != null) {
      Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  }

  void _setupVisibilityChangeListener() {
    if (kIsWeb) {
      // Only set up visibility listener for web platform
      // For mobile platforms, this is not needed
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
