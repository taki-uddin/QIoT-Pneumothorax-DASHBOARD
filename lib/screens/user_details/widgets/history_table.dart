import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pneumothoraxdashboard/constants/app_colors.dart';

class HistoryTable extends StatelessWidget {
  final List<dynamic> data;
  final String valueField;
  final String valueColumnTitle;

  const HistoryTable({
    super.key,
    required this.data,
    required this.valueField,
    required this.valueColumnTitle,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MMM d, yyyy hh:mm a');
    final double screenRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;

    print(
        'height: ${MediaQuery.of(context).size.height} and width: ${MediaQuery.of(context).size.width}');

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Table(
        border: TableBorder.all(
          color: AppColors.primaryBlue,
          width: 2,
          borderRadius: BorderRadius.circular(screenRatio),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
            ),
            children: [
              TableCell(
                child: SizedBox(
                  height: 60.0, 
                  child: Center(
                    child: Text(
                      'Date and Time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryWhite,
                        fontSize: screenRatio * 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ),
              TableCell(
                child: SizedBox(
                  height: 60.0,
                  child: Center(
                    child: Text(
                      valueColumnTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryWhite,
                        fontSize: screenRatio * 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ...data.map(
            (item) {
              final createdAt = DateTime.tryParse(item['createdAt']);
              final formattedDate = createdAt != null
                  ? dateFormat.format(createdAt)
                  : 'Invalid Date';
              final value = item[valueField]?.toString() ?? 'N/A';
              return TableRow(
                children: [
                  TableCell(
                    child: SizedBox(
                      height: 32.0, 
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenRatio * 2,
                              vertical: screenRatio),
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: screenRatio * 24,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: SizedBox(
                      height: 32.0, 
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenRatio * 2,
                              vertical: screenRatio),
                          child: Text(
                            value,
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: screenRatio * 24,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ).toList(),
        ],
      ),
    );
  }
}
