import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pneumothoraxdashboard/screens/dashboard_screen/dashboard_screen.dart';
import 'package:pneumothoraxdashboard/screens/authentication_screen/signin_screen.dart';
import 'package:pneumothoraxdashboard/screens/user_details/user_details.dart';

void defineRoutes(FluroRouter router) {
  router.define(
    '/',
    handler: Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
        return const SigninScreen();
      },
    ),
  );
  router.define(
    '/dashboard',
    handler: Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
        return DashboardScreen(
          router: router,
        );
      },
    ),
  );
  router.define(
    '/usersdetails/:id',
    handler: Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
        final String? userId = params['id']?.first;
        if (userId == null) {
          // Handle the case where userId is null
          return const SigninScreen(); // or any other fallback screen
        }
        return UserDetails(
          userId: userId,
        );
      },
    ),
  );
}
