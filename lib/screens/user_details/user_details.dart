import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
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
import 'package:printing/printing.dart';
import 'package:pneumothoraxdashboard/screens/user_details/widgets/notes_card_widget.dart';

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
  int _selectedTabIndex = 0; // For mobile tab navigation

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
      _selectedStartDate?.month ?? int.parse(DateTime.now().month.toString()),
      _selectedStartDate?.year ?? int.parse(DateTime.now().year.toString()),
      _selectedEndDate?.month ?? int.parse(DateTime.now().month.toString()),
      _selectedEndDate?.year ?? int.parse(DateTime.now().year.toString()),
    ).then(
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
    // Use mobile layout for narrow screens (< 768px) or native mobile platforms
    final bool isMobile = screenSize.width < 768 ||
        (!kIsWeb && (Platform.isAndroid || Platform.isIOS));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: hasData == false // Check if the data is available
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : isMobile
                ? _buildMobileLayout(screenSize, screenRatio)
                : _buildWebLayout(screenSize, screenRatio),
      ),
    );
  }

  Widget _buildWebLayout(Size screenSize, double screenRatio) {
    return Container(
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
                    'Name: ${userData['firstName']} ${userData['lastName']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'Weight: ${userData['weight']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'Body Temperature: ${userData['temperature']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'Heart Rate: ${userData['heartRate']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'Blood Pressure: ${userData['bloodPressure']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'Post Operative Day: ${userData['postOperativeDay']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  MedicationTable(
                    medications: userData['medications'],
                    screenRatio: screenRatio,
                  ),
                ],
              ),
            ),
            SizedBox(width: screenSize.width * 0.02),
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
                  SizedBox(height: screenSize.height * 0.02),
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
                      SizedBox(width: screenRatio * 8),
                      Text(
                        drainageRateHistory.isNotEmpty
                            ? DateFormat('MMM d, yyyy hh:mm a').format(
                                DateTime.parse(
                                  drainageRateHistory.last['createdAt'],
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
                  SizedBox(height: screenSize.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Download report:',
                        style: TextStyle(
                            fontSize: screenRatio * 8,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryBlue),
                      ),
                      SizedBox(width: screenRatio * 8),
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
                            _selectedEndDate != null
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
                  SizedBox(height: screenSize.height * 0.02),
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
                  SizedBox(height: screenSize.height * 0.02),
                  Expanded(
                    child: HistoryTable(
                      data: showDrainageRate
                          ? drainageRateHistory
                          : respiratoryRateHistory,
                      valueSecondField:
                          showDrainageRate ? 'drainageRate' : 'respiratoryRate',
                      valueSecondColumn: showDrainageRate
                          ? 'Drainage Rate\n(mL/min)'
                          : 'Respiratory Rate\n(bpm)',
                      valueThirdColumn:
                          showDrainageRate ? 'Drainage Noise' : '',
                      valueThirdField: showDrainageRate ? 'drainageNoise' : '',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: screenSize.width * 0.02),
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
                          SizedBox(height: screenSize.height * 0.02),
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
                          SizedBox(height: screenSize.height * 0.02),
                          SizedBox(
                            height: screenSize.height * 0.88,
                            child: getAllNotesData.isEmpty
                                ? const Center(
                                    child: Text('No notes available'),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.all(screenRatio * 4),
                                    itemCount: getAllNotesData.length,
                                    itemBuilder: (context, index) {
                                      final notes = getAllNotesData[index];
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
    );
  }

  Widget _buildMobileLayout(Size screenSize, double screenRatio) {
    return Column(
      children: [
        // Top App Bar
        SafeArea(
          bottom: false,
          child: Container(
            width: screenSize.width,
            height: screenSize.height * 0.08,
            color: const Color(0xFF004283),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                // Title
                Text(
                  '${userData['firstName']} ${userData['lastName']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Download Button
                IconButton(
                  onPressed: () {
                    setState(() {
                      downloadReport = true;
                    });
                    getDrainageRateHistories(widget.userId);
                  },
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Tab Bar
        Container(
          width: screenSize.width,
          height: screenSize.height * 0.06,
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: _buildMobileTab('Patient Info', 0),
              ),
              Expanded(
                child: _buildMobileTab('Vitals', 1),
              ),
              Expanded(
                child: _buildMobileTab('History', 2),
              ),
              Expanded(
                child: _buildMobileTab('Media', 3),
              ),
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: _buildMobileContent(screenSize, screenRatio),
        ),
      ],
    );
  }

  Widget _buildMobileTab(String title, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF004283) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF004283) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileContent(Size screenSize, double screenRatio) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPatientInfoTab(screenSize, screenRatio);
      case 1:
        return _buildVitalsTab(screenSize, screenRatio);
      case 2:
        return _buildHistoryTab(screenSize, screenRatio);
      case 3:
        return _buildMediaTab(screenSize, screenRatio);
      default:
        return _buildPatientInfoTab(screenSize, screenRatio);
    }
  }

  Widget _buildPatientInfoTab(Size screenSize, double screenRatio) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
              'Name', '${userData['firstName']} ${userData['lastName']}'),
          _buildInfoCard('Weight', '${userData['weight']}'),
          _buildInfoCard('Body Temperature', '${userData['temperature']}'),
          _buildInfoCard('Heart Rate', '${userData['heartRate']}'),
          _buildInfoCard('Blood Pressure', '${userData['bloodPressure']}'),
          _buildInfoCard(
              'Post Operative Day', '${userData['postOperativeDay']}'),
          const SizedBox(height: 16),
          const Text(
            'Medications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004283),
            ),
          ),
          const SizedBox(height: 8),
          MedicationTable(
            medications: userData['medications'],
            screenRatio: screenRatio,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsTab(Size screenSize, double screenRatio) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildVitalCard(
                  'Drainage Rate',
                  '${userData['drainageRate']}',
                  const Color(0xFF27AE60),
                  () {
                    getDrainageRateHistories(widget.userId);
                    setState(() {
                      showDrainageRate = true;
                      showRespiratoryRate = false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVitalCard(
                  'Respiratory Rate',
                  '${userData['respiratoryRate']}',
                  const Color(0xFFFD4646),
                  () {
                    getRespiratoryRateHistories(widget.userId);
                    setState(() {
                      showDrainageRate = false;
                      showRespiratoryRate = true;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildVitalCard(
            'Blood Saturation',
            '${userData['bloodSaturation']}',
            const Color(0xFFFF8500),
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(Size screenSize, double screenRatio) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Date Selection
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _selectStartDate(context),
                  child: Text(
                    _selectedStartDate != null
                        ? '${_selectedStartDate?.month}/${_selectedStartDate?.year}'
                        : 'Start Date',
                    style: const TextStyle(color: Color(0xFF004283)),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _selectEndDate(context),
                  child: Text(
                    _selectedEndDate != null
                        ? '${_selectedEndDate?.month}/${_selectedEndDate?.year}'
                        : 'End Date',
                    style: const TextStyle(color: Color(0xFF004283)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart
          Container(
            height: screenSize.height * 0.3,
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
          const SizedBox(height: 16),
          // Table
          HistoryTable(
            data:
                showDrainageRate ? drainageRateHistory : respiratoryRateHistory,
            valueSecondField:
                showDrainageRate ? 'drainageRate' : 'respiratoryRate',
            valueSecondColumn: showDrainageRate
                ? 'Drainage Rate\n(mL/min)'
                : 'Respiratory Rate\n(bpm)',
            valueThirdColumn: showDrainageRate ? 'Drainage Noise' : '',
            valueThirdField: showDrainageRate ? 'drainageNoise' : '',
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTab(Size screenSize, double screenRatio) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Color(0xFF004283),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF004283),
              tabs: [
                Tab(text: 'Images'),
                Tab(text: 'Notes'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Images Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ImageGalleryWidget(
                    getAllImagesHistory: getAllImagesHistory,
                    screenRatio: screenRatio,
                  ),
                ),
                // Notes Tab
                getAllNotesData.isEmpty
                    ? const Center(child: Text('No notes available'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: getAllNotesData.length,
                        itemBuilder: (context, index) {
                          final notes = getAllNotesData[index];
                          return NoteCardWidget(
                            note: notes,
                            screenRatio: screenRatio,
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004283),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(
      String label, String value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
