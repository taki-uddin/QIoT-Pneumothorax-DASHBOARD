import 'package:flutter/material.dart';

class ButtonTabWidget extends StatelessWidget {
  final String label;
  final Color color;
  final dynamic value;
  final VoidCallback onTap;
  final double screenRatio;

  const ButtonTabWidget({
    super.key,
    required this.label,
    required this.color,
    required this.value,
    required this.onTap,
    required this.screenRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenRatio * 128,
        height: MediaQuery.of(context).size.height * 0.08,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              offset: Offset(0.0, 1.0),
              blurRadius: 2.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: screenRatio * 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Container(
              width: screenRatio * 32,
              height: MediaQuery.of(context).size.height * 0.06,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.04),
                    offset: Offset(0.0, 1.0),
                    blurRadius: 2.0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenRatio * 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
