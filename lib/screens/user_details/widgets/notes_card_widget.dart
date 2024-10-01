import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pneumothoraxdashboard/constants/app_colors.dart';

class NoteCardWidget extends StatelessWidget {
  final Map<String, dynamic> note;
  final double screenRatio;

  const NoteCardWidget({
    super.key,
    required this.note,
    required this.screenRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: note['painRating'] == "Low"
            ? const Icon(
                Icons.sentiment_satisfied_sharp,
                color: Colors.green,
              )
            : note['painRating'] == "Medium"
                ? const Icon(
                    Icons.sentiment_neutral,
                    color: Colors.amber,
                  )
                : const Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.red,
                  ),
        title: Text(
          note['title'],
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: screenRatio * 7,
            fontWeight: FontWeight.normal,
            fontFamily: 'Roboto',
          ),
        ),
        subtitle: Text(
          note['description'],
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: screenRatio * 5,
            fontWeight: FontWeight.normal,
            fontFamily: 'Roboto',
          ),
        ),
        trailing: Text(
          DateFormat('dd/MM/yyyy').format(DateTime.parse(note['createdAt'])),
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: screenRatio * 5,
            fontWeight: FontWeight.normal,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}
