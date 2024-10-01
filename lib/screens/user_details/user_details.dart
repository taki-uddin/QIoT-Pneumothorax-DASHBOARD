import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pneumothoraxdashboard/constants/app_colors.dart';
import 'package:pneumothoraxdashboard/main.dart';
import 'package:pneumothoraxdashboard/screens/user_details/widgets/button_tab_widget.dart';
import 'package:pneumothoraxdashboard/screens/user_details/widgets/history_chart.dart';
import 'package:pneumothoraxdashboard/screens/user_details/widgets/history_table.dart';
import 'package:pneumothoraxdashboard/api/dashboard_users_data.dart';
import 'package:pneumothoraxdashboard/screens/user_details/widgets/image_gallery_widget.dart';
import 'package:pneumothoraxdashboard/screens/user_details/widgets/medication_table.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pneumothoraxdashboard/screens/user_details/widgets/notes_card_widget.dart';
import 'package:printing/printing.dart';

class UserDetails extends StatefulWidget {
  final String userId; // Add a field to store the user ID
  const UserDetails({super.key, required this.userId});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  Map<String, dynamic> userData = {};
  List<dynamic> drainageRateHistory = [];
  List<dynamic> respiratoryRateHistory = [];
  List<dynamic> getAllImagesHistory = [];
  List<dynamic> getAllNotesData = [];
  bool hasData = false;
  bool showDrainageRate = true;
  bool showRespiratoryRate = true;
  bool downloadReport = false;
  String userId = '';
  DateTime? _selectedStartDate, _selectedEndDate;

  @override
  void initState() {
    super.initState();
    setState(() {
      userId = widget.userId;
    });
    getUserByIdData(userId);
    getDrainageRateHistories(userId);
    getAllImages(userId);
    getAllNotes(userId);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default selection
      firstDate: DateTime(2000), // Minimum date
      lastDate: DateTime(2100), // Maximum date
    );

    // If the user selected a date, update the state
    if (pickedDate != null && pickedDate != _selectedStartDate) {
      setState(() {
        _selectedStartDate = pickedDate;
      });
      logger.d('${_selectedStartDate?.month} ${_selectedStartDate?.year}');
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default selection
      firstDate: DateTime(2000), // Minimum date
      lastDate: DateTime(2100), // Maximum date
    );

    // If the user selected a date, update the state
    if (pickedDate != null && pickedDate != _selectedEndDate) {
      setState(() {
        _selectedEndDate = pickedDate;
      });
      logger.d('${_selectedEndDate?.month} ${_selectedEndDate?.year}');
    }
  }

  Future<void> getUserByIdData(String userId) async {
    DashboardUsersData.getUserByIdData(userId).then(
      (value) async {
        if (value != null) {
          setState(() {
            userData = value['payload'];
            hasData = true;
          });
        } else {
          logger.d('Failed to get user data');
        }
      },
    );
  }

  Future<void> getDrainageRateHistories(String userId) async {
    logger.d(
        'Start date: ${_selectedStartDate?.month} ${_selectedStartDate?.year}');
    logger.d('End date: ${_selectedEndDate?.month} ${_selectedEndDate?.year}');
    DashboardUsersData.getDrainageRateHistories(
            userId,
            _selectedStartDate?.month ??
                int.parse(DateTime.now().month.toString()),
            _selectedStartDate?.year ??
                int.parse(DateTime.now().year.toString()),
            _selectedEndDate?.month ??
                int.parse(DateTime.now().month.toString()),
            _selectedEndDate?.year ?? int.parse(DateTime.now().year.toString()))
        .then(
      (value) async {
        logger.d('Drainage rate histories: $value');
        if (value != null) {
          final payload = value['payload'];
          setState(() {
            drainageRateHistory = payload['drainageRateHistory'];
          });
          if (downloadReport) {
            await generatePDFReport(drainageRateHistory);
            setState(() {
              downloadReport = false;
            });
          }
        } else {
          logger.d('Failed to get user data');
        }
      },
    );
  }

  Future<void> getRespiratoryRateHistories(String userId) async {
    logger.d('Clicked on respiratory rate function');
    DashboardUsersData.getRespiratoryRateHistories(
            userId,
            int.parse(DateTime.now().month.toString()),
            int.parse(DateTime.now().year.toString()))
        .then(
      (value) async {
        logger.d('Respiratory rate histories: $value');
        if (value != null) {
          final payload = value['payload'];
          setState(() {
            respiratoryRateHistory = payload['respiratoryRateHistory'];
          });
        } else {
          logger.d('Failed to get user data');
        }
      },
    );
  }

  Future<void> getAllImages(String userId) async {
    DashboardUsersData.getAllImages(
      userId,
    ).then(
      (value) async {
        if (value != null) {
          final payload = value['payload'];
          setState(() {
            getAllImagesHistory = payload;
          });
        } else {
          logger.d('Failed to get image data');
        }
      },
    );
  }

  Future<void> getAllNotes(String userId) async {
    DashboardUsersData.getAllNotes(
      userId,
    ).then(
      (value) async {
        if (value != null) {
          final payload = value['payload'];
          setState(() {
            getAllNotesData = payload;
          });
          logger.d('All notes data: $getAllNotesData');
        } else {
          logger.d('Failed to get image data');
        }
      },
    );
  }

  Future<void> generatePDFReport(List<dynamic> drainageRateHistory) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Drainage Rate Report',
                  style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<dynamic>>[
                  <String>['Date', 'Drainage Rate (mL/min)', 'Noise'],
                  ...drainageRateHistory
                      .map(
                        (item) => [
                          DateFormat('MMM d, yyyy')
                              .format(DateTime.parse(item['createdAt'])),
                          item['drainageRate'].toString(),
                          item['drainageNoise']
                        ],
                      )
                      .toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Trigger the print dialog or save the PDF
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: hasData == false // Check if the data is available
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: EdgeInsets.all(screenSize.width * 0.01),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Container
                      SizedBox(
                        width: screenSize.width * 0.22,
                        height: screenSize.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${userData['firstName']} ${userData['lastName']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Text(
                              'Weight: ${userData['weight']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Text(
                              'Body Temperature: ${userData['temperature']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Text(
                              'Heart Rate: ${userData['heartRate']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Text(
                              'Blood Pressure: ${userData['bloodPressure']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Text(
                              'Post Operative Day: ${userData['postOperativeDay']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            MedicationTable(
                              medications: userData['medications'],
                              screenRatio: screenRatio,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: screenSize.width * 0.02,
                      ),
                      // Middle Container
                      SizedBox(
                        width: screenSize.width * 0.56,
                        height: screenSize.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ButtonTabWidget(
                                  label: 'Drainage Rate',
                                  color: const Color(0xFF27AE60),
                                  value: userData['drainageRate'],
                                  onTap: () {
                                    getDrainageRateHistories(widget.userId);
                                    setState(() {
                                      showDrainageRate = true;
                                      showRespiratoryRate = false;
                                    });
                                  },
                                  screenRatio: screenRatio,
                                ),
                                ButtonTabWidget(
                                  label: 'Respiratory Rate',
                                  color: const Color(0xFFFD4646),
                                  value: userData['respiratoryRate'],
                                  onTap: () {
                                    getRespiratoryRateHistories(widget.userId);
                                    setState(() {
                                      showDrainageRate = false;
                                      showRespiratoryRate = true;
                                    });
                                  },
                                  screenRatio: screenRatio,
                                ),
                                ButtonTabWidget(
                                  label: 'Blood Saturation',
                                  color: const Color(0xFFFF8500),
                                  value: userData['bloodSaturation'],
                                  onTap: () {
                                    // Handle blood saturation tap
                                  },
                                  screenRatio: screenRatio,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Last recorded on:',
                                  style: TextStyle(
                                      fontSize: screenRatio * 8,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.primaryBlue),
                                ),
                                SizedBox(
                                  width: screenRatio * 8,
                                ),
                                Text(
                                  drainageRateHistory.isNotEmpty
                                      ? DateFormat('MMM d, yyyy hh:mm a')
                                          .format(
                                          DateTime.parse(
                                            drainageRateHistory
                                                .last['createdAt'],
                                          ),
                                        )
                                      : 'N/A',
                                  style: TextStyle(
                                      fontSize: screenRatio * 8,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Dowmload report:',
                                  style: TextStyle(
                                      fontSize: screenRatio * 8,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.primaryBlue),
                                ),
                                SizedBox(
                                  width: screenRatio * 8,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        _selectStartDate(context);
                                      },
                                      child: Text(
                                        'Start MM/YYYY',
                                        style: TextStyle(
                                          fontSize: screenRatio * 8,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _selectedStartDate != null
                                          ? '${_selectedStartDate?.month} / ${_selectedStartDate?.year}'
                                          : 'N/A',
                                      style: TextStyle(
                                        fontSize: screenRatio * 8,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        _selectEndDate(context);
                                      },
                                      child: Text(
                                        'End MM/YYYY',
                                        style: TextStyle(
                                          fontSize: screenRatio * 8,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _selectedStartDate != null
                                          ? '${_selectedEndDate?.month} / ${_selectedEndDate?.year}'
                                          : 'N/A',
                                      style: TextStyle(
                                        fontSize: screenRatio * 8,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      downloadReport = true;
                                    });
                                    getDrainageRateHistories(widget.userId);
                                  },
                                  icon: Icon(
                                    Icons.download,
                                    color: AppColors.primaryBlue,
                                    size: screenRatio * 16,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            SizedBox(
                              height: screenSize.height * 0.5,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: showDrainageRate
                                      ? HistoryChart(
                                          data: drainageRateHistory,
                                          yAxisField: 'drainageRate',
                                        )
                                      : showRespiratoryRate
                                          ? HistoryChart(
                                              data: respiratoryRateHistory,
                                              yAxisField: 'respiratoryRate',
                                            )
                                          : const SizedBox.shrink(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Expanded(
                              child: HistoryTable(
                                data: showDrainageRate
                                    ? drainageRateHistory
                                    : respiratoryRateHistory,
                                valueSecondField: showDrainageRate
                                    ? 'drainageRate'
                                    : 'respiratoryRate',
                                valueSecondColumn: showDrainageRate
                                    ? 'Drainage Rate\n(mL/min)'
                                    : 'Respiratory Rate\n(bpm)',
                                valueThirdColumn:
                                    showDrainageRate ? 'Drainage Noise' : '',
                                valueThirdField:
                                    showDrainageRate ? 'drainageNoise' : '',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: screenSize.width * 0.02,
                      ),
                      // Right Container
                      SizedBox(
                        width: screenSize.width * 0.16,
                        height: screenSize.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: screenSize.height * 0.48,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text(
                                      'Images',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: screenRatio * 10,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(
                                      height: screenSize.height * 0.02,
                                    ),
                                    SizedBox(
                                      height: screenSize.height * 0.88,
                                      child: ImageGalleryWidget(
                                        getAllImagesHistory:
                                            getAllImagesHistory,
                                        screenRatio: screenRatio,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.48,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text(
                                      'Notes',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: screenRatio * 10,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(
                                      height: screenSize.height * 0.02,
                                    ),
                                    SizedBox(
                                      height: screenSize.height * 0.88,
                                      child: getAllNotesData.isEmpty
                                          ? const Center(
                                              child: Text('No notes available'),
                                            )
                                          : ListView.builder(
                                              padding: EdgeInsets.all(
                                                  screenRatio * 4),
                                              itemCount: getAllNotesData.length,
                                              itemBuilder: (context, index) {
                                                final notes =
                                                    getAllNotesData[index];
                                                return NoteCardWidget(
                                                  note: notes,
                                                  screenRatio: screenRatio,
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
