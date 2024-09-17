import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

class WebRouterProvider extends StatelessWidget {
  final FluroRouter router;

  final Widget child;

  const WebRouterProvider({
    super.key,
    required this.router,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
