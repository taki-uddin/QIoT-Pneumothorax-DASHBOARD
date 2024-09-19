import 'package:flutter/material.dart';
import 'package:pneumothoraxdashboard/constants/app_colors.dart';
import 'package:pneumothoraxdashboard/screens/user_details/widgets/button_tab_widget.dart';
import 'package:pneumothoraxdashboard/screens/user_details/widgets/history_chart.dart';
import 'package:pneumothoraxdashboard/screens/user_details/widgets/history_table.dart';
import 'package:pneumothoraxdashboard/api/dashboard_users_data.dart';
import 'package:pneumothoraxdashboard/screens/user_details/widgets/image_gallery_widget.dart';

class UserDetails extends StatefulWidget {
  final String userId; // Add a field to store the user ID
  const UserDetails({super.key, required this.userId});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  List<dynamic> userData = [];
  List<dynamic> drainageRateHistory = [];
  List<dynamic> respiratoryRateHistory = [];
  List<dynamic> getAllImagesHistory = [];
  bool hasData = false;
  bool showDrainageRate = true;
  bool showRespiratoryRate = true;
  String userId = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      userId = widget.userId;
    });
    getUserByIdData(widget.userId);
    getDrainageRateHistories(widget.userId);
    getAllImages(widget.userId);
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
          print('Failed to get user data');
        }
      },
    );
  }

  Future<void> getDrainageRateHistories(String userId) async {
    DashboardUsersData.getDrainageRateHistories(
            userId,
            int.parse(DateTime.now().month.toString()),
            int.parse(DateTime.now().year.toString()))
        .then(
      (value) async {
        if (value != null) {
          final payload = value['payload'];
          setState(() {
            drainageRateHistory = payload['drainageRateHistory'];
          });
        } else {
          print('Failed to get user data');
        }
      },
    );
  }

  Future<void> getRespiratoryRateHistories(String userId) async {
    DashboardUsersData.getRespiratoryRateHistories(
            userId,
            int.parse(DateTime.now().month.toString()),
            int.parse(DateTime.now().year.toString()))
        .then(
      (value) async {
        if (value != null) {
          final payload = value['payload'];
          setState(() {
            respiratoryRateHistory = payload['respiratoryRateHistory'];
          });
        } else {
          print('Failed to get user data');
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

          print('Images: $getAllImagesHistory');
        } else {
          print('Failed to get image data');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    print('Screen ratio: $screenRatio');

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
                        width: screenSize.width * 0.2,
                        height: screenSize.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${userData[0]['firstName']} ${userData[0]['lastName']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Text(
                              'Weight: ${userData[0]['weight']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Text(
                              'Body Temperature: ${userData[0]['temeprature']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Text(
                              'Heart Rate: ${userData[0]['heartRate']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Text(
                              'Blood Pressure: ${userData[0]['bloodPressure']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            Text(
                              'Post Operative Day: ${userData[0]['postOperativeDay']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            SizedBox(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Table(
                                    border: TableBorder.all(
                                      color: AppColors.primaryBlue,
                                      width: 2,
                                      borderRadius:
                                          BorderRadius.circular(screenRatio),
                                    ),
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
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
                                                  'Medication',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.primaryWhite,
                                                    fontSize: screenRatio * 8,
                                                    fontWeight:
                                                        FontWeight.normal,
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
                                                  'Dosage',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.primaryWhite,
                                                    fontSize: screenRatio * 8,
                                                    fontWeight:
                                                        FontWeight.normal,
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
                                                  'Frequency',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.primaryWhite,
                                                    fontSize: screenRatio * 8,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontFamily: 'Roboto',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ...List.generate(
                                        5,
                                        (index) => TableRow(
                                          children: [
                                            TableCell(
                                              child: SizedBox(
                                                height: 32.0,
                                                child: Center(
                                                  child: Text(
                                                    'Medication Name',
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.primaryBlue,
                                                      fontSize: screenRatio * 6,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: SizedBox(
                                                height: 32.0,
                                                child: Center(
                                                  child: Text(
                                                    'Dosage',
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.primaryBlue,
                                                      fontSize: screenRatio * 6,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: SizedBox(
                                                height: 32.0,
                                                child: Center(
                                                  child: Text(
                                                    'Frequency',
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.primaryBlue,
                                                      fontSize: screenRatio * 6,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
                        width: screenSize.width * 0.58,
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
                                  value: userData[0]['drainageRate'],
                                  onTap: () {
                                    getDrainageRateHistories(
                                        userData[0]['_id']);
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
                                  value: userData[0]['respiratoryRate'],
                                  onTap: () {
                                    getRespiratoryRateHistories(
                                        userData[0]['_id']);
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
                                  value: userData[0]['bloodSaturation'],
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
                            Text(
                              'Images',
                              style: TextStyle(
                                fontSize: screenRatio * 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.02,
                            ),
                            SizedBox(
                              height: screenSize.height * 0.88,
                              child: ImageGalleryWidget(
                                getAllImagesHistory: getAllImagesHistory,
                                screenRatio: screenRatio,
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
