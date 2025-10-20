import 'package:flutter/material.dart';
import 'package:pneumothoraxdashboard/constants/app_colors.dart';

class MedicationTable extends StatelessWidget {
  final List<dynamic> medications;
  final double screenRatio;

  const MedicationTable({
    super.key,
    required this.medications,
    required this.screenRatio,
  });

  @override
  Widget build(BuildContext context) {
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
            _buildHeaderCell('Medication Name', screenRatio),
            _buildHeaderCell('Dosage', screenRatio),
            _buildHeaderCell('Frequency', screenRatio),
            _buildHeaderCell('Remarks', screenRatio),
          ],
        ),
        ...medications.map(
          (item) {
            return TableRow(
              children: [
                _buildDataCell('${item['medicationName']}', screenRatio),
                _buildDataCell('${item['dosage']}', screenRatio),
                _buildDataCell('${item['frequency']}', screenRatio),
                _buildDataCell('${item['remarks']}', screenRatio),
              ],
            );
          },
        ).toList(),
      ],
    );
  }

  TableCell _buildHeaderCell(String text, double screenRatio) {
    // Use a larger font size for mobile
    final double fontSize = screenRatio * 10 < 16 ? 16 : screenRatio * 10;
    return TableCell(
      child: SizedBox(
        height: 60.0,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }

  TableCell _buildDataCell(String text, double screenRatio) {
    // Use a larger font size for mobile
    final double fontSize = screenRatio * 9 < 15 ? 15 : screenRatio * 9;
    return TableCell(
      child: SizedBox(
        height: 36.0,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenRatio, vertical: screenRatio),
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: fontSize,
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
