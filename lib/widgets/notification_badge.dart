import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int? count;

  const NotificationBadge({
    Key? key,
    required this.child,
    this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      clipBehavior: Clip.none,
      children: [
        child,
        if (count != null && count! > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12.0),
              ),
              constraints: BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
