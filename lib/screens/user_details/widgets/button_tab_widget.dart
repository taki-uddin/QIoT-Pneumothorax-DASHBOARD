import 'package:flutter/material.dart';

class ButtonTabWidget extends StatelessWidget {
  final String label;
  final Color color;
  final dynamic value;
  final VoidCallback onTap;

  const ButtonTabWidget({
    super.key,
    required this.label,
    required this.color,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
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
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.04,
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
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
