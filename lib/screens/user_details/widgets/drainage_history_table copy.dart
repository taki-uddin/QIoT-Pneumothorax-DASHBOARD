import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pneumothoraxdashboard/constants/app_colors.dart';

class DrainageHistoryTable extends StatelessWidget {
  final List<dynamic> drainageRateHistory;

  const DrainageHistoryTable({super.key, required this.drainageRateHistory});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MMM d, yyyy hh:mm a');
    final double screenRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;

    return Table(
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
              child: Text(
                'Date and Time',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: screenRatio * 8,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            TableCell(
              child: Text(
                'Drainage Rate\n(mL/min)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: screenRatio * 8,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ],
        ),
        ...drainageRateHistory.map(
          (item) {
            final createdAt = DateTime.parse(item['createdAt']);
            final formattedDate = dateFormat.format(createdAt);
            return TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenRatio * 2, vertical: screenRatio),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: screenRatio * 7,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenRatio * 2, vertical: screenRatio),
                    child: Text(
                      '${item['drainageRate']}',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: screenRatio * 7,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ).toList(),
      ],
    );
  }
}
