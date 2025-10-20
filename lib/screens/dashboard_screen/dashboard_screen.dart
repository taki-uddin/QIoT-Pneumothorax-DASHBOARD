import 'package:file_picker/file_picker.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdfx/pdfx.dart';
import 'package:pneumothoraxdashboard/data/top_menu_data.dart';
import 'package:pneumothoraxdashboard/helpers/session_storage_helpers.dart';
import 'package:pneumothoraxdashboard/main.dart';
import 'package:pneumothoraxdashboard/screens/add_users_screen.dart';
import 'package:pneumothoraxdashboard/screens/notifications_screen.dart';
import 'package:pneumothoraxdashboard/screens/user_list_screen.dart';
import 'package:pneumothoraxdashboard/api/authentication.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:pneumothoraxdashboard/api/dashboard_users_data.dart';

class DashboardScreen extends StatefulWidget {
  final FluroRouter router;
  const DashboardScreen({super.key, required this.router});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final data = TopMenuData();
  dynamic _selectedFile;
  String pdfUrl = '';
  PdfControllerPinch? pdfPinchController;

  @override
  void initState() {
    super.initState();
    _printToken();
  }

  Future<void> loadPdfDocument() async {
    // Fetch PDF bytes asynchronously
    final Uint8List bytes = await fetchPdfBytes(pdfUrl);
    // Initialize PdfControllerPinch with document
    pdfPinchController = PdfControllerPinch(
      document: PdfDocument.openData(bytes),
    );
    // Update UI
    setState(() {});
  }

  Future<Uint8List> fetchPdfBytes(String pdfUrl) async {
    final response = await http.get(Uri.parse(pdfUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load PDF: ${response.statusCode}');
    }
  }

  Future<void> uploadEP() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.single;

      setState(() {
        if (kIsWeb) {
          // For web platform
          _selectedFile = file;
        } else {
          // For mobile platforms
          _selectedFile = file;
        }
      });

      try {
        final Map<String, dynamic>? uploadUserAAP =
            await DashboardUsersData().uploadEducationalPlan(_selectedFile!);
        if (uploadUserAAP != null) {
          logger.d('Your Asthma Action Plan has been uploaded!');
        } else {
          logger.d('Failed to upload Asthma Action Plan');
        }
      } catch (e) {
        logger.d('Error: $e');
      }
    } else {
      logger.d('No file selected');
    }
  }

  Future<void> _printToken() async {
    logger.d(
        'Dashboard Access Token: ${await SessionStorageHelpers.getStorage('accessToken')}');
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    // Use mobile layout for narrow screens (< 768px) or native mobile platforms
    final bool isMobile = screenSize.width < 768 ||
        (!kIsWeb && (Platform.isAndroid || Platform.isIOS));

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: isMobile
            ? _buildMobileLayout(screenSize)
            : _buildWebLayout(screenSize),
        bottomNavigationBar: isMobile ? _buildBottomNavigationBar() : null,
      ),
    );
  }

  Widget _buildWebLayout(Size screenSize) {
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Container
          Container(
            width: 240,
            height: screenSize.height,
            color: const Color(0xFF004283).withOpacity(0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SvgPicture.asset(
                          'assets/svg/logo.svg',
                          width: 140,
                        ),
                      ),
                      const Divider(
                        indent: 16,
                        endIndent: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            height: screenSize.height * 0.4,
                            child: ListView.builder(
                              itemCount: data.menu.length,
                              itemBuilder: (context, index) =>
                                  _buildMenu(data, index),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Divider(
                        indent: 16,
                        endIndent: 16,
                      ),
                      ListTile(
                        onTap: () async {
                          Map<String, dynamic> signOutResult =
                              await Authentication.signOut();
                          bool signOutSuccess =
                              signOutResult['success'] ?? false;
                          String? errorMessage = signOutResult['error'];
                          if (signOutSuccess) {
                            Navigator.popAndPushNamed(context, '/');
                          } else {
                            // Authentication failed
                            logger.d('Authentication failed: $errorMessage');
                          }
                        },
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Middle Container
          Expanded(
            child: Container(
              height: screenSize.height,
              child: getCustomMenu(),
            ),
          ),
          // Right Container
          Container(
            width: 240,
            height: screenSize.height,
            color: const Color(0xFFFFFFFF),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 220,
                  height: 180,
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004283).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Educational Plan',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF004283),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: SvgPicture.asset(
                          'assets/svg/personal_plan.svg',
                          width: 80,
                          height: 80,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          uploadEP();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004283),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Upload',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 220,
                  height: 280,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF004283).withOpacity(0.2),
                    ),
                  ),
                  child: pdfPinchController != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: PdfViewPinch(
                            controller: pdfPinchController!,
                          ),
                        )
                      : const Center(
                          child: Text(
                            'No PDF loaded',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(Size screenSize) {
    return SafeArea(
      child: Column(
        children: [
          // Top App Bar
          Container(
            width: screenSize.width,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF004283),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: SvgPicture.asset(
                    'assets/svg/logo.svg',
                    width: screenSize.width * 0.12,
                    height: 32,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                // Title
                Expanded(
                  child: Center(
                    child: Text(
                      data.menu[_selectedIndex].title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Menu Button
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'upload') {
                        uploadEP();
                      } else if (value == 'logout') {
                        _handleLogout();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'upload',
                        child: Row(
                          children: [
                            Icon(Icons.upload_file, size: 20),
                            SizedBox(width: 12),
                            Text('Upload Educational Plan'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 12),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: getCustomMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFFFFF),
        selectedItemColor: const Color(0xFF004283),
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        elevation: 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle_rounded),
            activeIcon: Icon(Icons.supervised_user_circle),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_outlined),
            activeIcon: Icon(Icons.person_add),
            label: 'Add Patient',
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    Map<String, dynamic> signOutResult = await Authentication.signOut();
    bool signOutSuccess = signOutResult['success'] ?? false;
    String? errorMessage = signOutResult['error'];
    if (signOutSuccess) {
      Navigator.popAndPushNamed(context, '/');
    } else {
      // Authentication failed
      logger.d('Authentication failed: $errorMessage');
    }
  }

  Widget _buildMenu(TopMenuData data, int index) {
    final bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 2.0,
      ),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004283) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                data.menu[index].icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF004283),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  data.menu[index].title,
                  style: TextStyle(
                    fontSize: isSelected ? 14.0 : 12.0,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF004283),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getCustomMenu() {
    logger.d(_selectedIndex);
    switch (_selectedIndex) {
      case 0:
        return const UserListScreen();
      case 1:
        return const NotificationsScreen();
      case 2:
        return const AddUsersScreen();
    }
    return const UserListScreen();
  }
}
