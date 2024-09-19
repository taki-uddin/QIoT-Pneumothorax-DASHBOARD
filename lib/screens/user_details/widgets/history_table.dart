import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pneumothoraxdashboard/constants/app_colors.dart';

class HistoryTable extends StatelessWidget {
  final List<dynamic> data;
  final String valueSecondField, valueThirdField;
  final String valueSecondColumn, valueThirdColumn;

  const HistoryTable({
    super.key,
    required this.data,
    required this.valueSecondField,
    required this.valueSecondColumn,
    required this.valueThirdField,
    required this.valueThirdColumn,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MMM d, yyyy hh:mm a');
    final double screenRatio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: data.isEmpty
          ? const Text(
              'No table data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            )
          : Table(
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
                    _buildHeaderCell('Date and Time', screenRatio),
                    _buildHeaderCell(valueSecondColumn, screenRatio),
                    if (valueThirdColumn.isNotEmpty)
                      _buildHeaderCell(valueThirdColumn, screenRatio),
                  ],
                ),
                ...data.map(
                  (item) {
                    final createdAt = DateTime.tryParse(item['createdAt']);
                    final formattedDate = createdAt != null
                        ? dateFormat.format(createdAt)
                        : 'Invalid Date';
                    final valueSecond =
                        item[valueSecondField]?.toString() ?? 'N/A';
                    final valueThird = valueThirdField.isNotEmpty
                        ? item[valueThirdField]?.toString() ?? 'N/A'
                        : null;
                    return TableRow(
                      children: [
                        _buildDataCell(formattedDate, screenRatio),
                        _buildDataCell(valueSecond, screenRatio),
                        if (valueThird != null)
                          _buildDataCell(valueThird, screenRatio),
                      ],
                    );
                  },
                ).toList(),
              ],
            ),
    );
  }

  TableCell _buildHeaderCell(String text, double screenRatio) {
    return TableCell(
      child: SizedBox(
        height: 60.0,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize: screenRatio * 8,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }

  TableCell _buildDataCell(String text, double screenRatio) {
    return TableCell(
      child: SizedBox(
        height: 32.0,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenRatio * 2, vertical: screenRatio),
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: screenRatio * 6,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
