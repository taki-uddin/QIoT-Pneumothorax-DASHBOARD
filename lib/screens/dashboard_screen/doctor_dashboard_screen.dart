import 'package:file_picker/file_picker.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdfx/pdfx.dart';
import 'package:pneumothoraxdashboard/data/top_menu_data.dart';
import 'package:pneumothoraxdashboard/helpers/session_storage_helpers.dart';
import 'package:pneumothoraxdashboard/main.dart';
import 'package:pneumothoraxdashboard/screens/notifications_screen.dart';
import 'package:pneumothoraxdashboard/screens/user_list_screen.dart';
import 'package:pneumothoraxdashboard/api/authentication.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import 'package:pneumothoraxdashboard/api/dashboard_users_data.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final FluroRouter router;
  final String? userRole;
  const DoctorDashboardScreen({super.key, required this.router, this.userRole});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _selectedIndex = 0;
  final data = TopMenuData();
  html.File? _selectedFile;
  String pdfUrl = '';
  PdfControllerPinch? pdfPinchController;

  @override
  void initState() {
    super.initState();
    getuserRole();
  }

  void getuserRole() async {
    final String? userRole = widget.userRole;
    logger.d('Admin screen User Role: $userRole');
  }

  Future<void> uploadEP() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.single;

      // Read the file bytes asynchronously
      List<int> bytes = file.bytes!.toList();

      setState(() {
        _selectedFile = html.File(bytes, file.name); // For web
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Container
                Container(
                  width: screenSize.width * 0.16,
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
                            SvgPicture.asset(
                              'assets/svg/logo.svg',
                              width: screenSize.width * 0.1,
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
                                  height: screenSize.height * 0.6,
                                  child: ListView.builder(
                                    itemCount: data.menu.length,
                                    itemBuilder: (context, index) =>
                                        widget.userRole == 'Doctor'
                                            ? _buildMenu(data, index - 1)
                                            : _buildMenu(data, index),
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
                                  logger.d(
                                      'Authentication failed: $errorMessage');
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
                SizedBox(
                  width: screenSize.width * 0.68,
                  height: screenSize.height,
                  child: Center(
                    child: FutureBuilder(
                      future: null,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return getCustomMenu();
                      },
                    ),
                  ),
                ), // Right Container
                // Right Container
                Container(
                  width: screenSize.width * 0.16,
                  height: screenSize.height,
                  color: const Color(0xFFFFFFFF),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: screenSize.width * 0.16,
                        height: screenSize.height * 0.4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004283).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Educational Plan',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF004283),
                              ),
                            ),
                            SizedBox(
                              width: screenSize.width * 0.1,
                              height: screenSize.height * 0.1,
                              child: SvgPicture.asset(
                                'assets/svg/personal_plan.svg',
                                width: 96,
                                height: 96,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                uploadEP();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF004283),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'Upload',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: screenSize.width * 0.16,
                        height: screenSize.height * 0.4,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        margin: const EdgeInsets.all(16.0),
                        child: pdfPinchController != null
                            ? PdfViewPinch(
                                controller: pdfPinchController!,
                              )
                            : const SizedBox(),
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
                color: isSelected
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF004283),
              ),
              const SizedBox(width: 8.0),
              Text(
                data.menu[index].title,
                style: TextStyle(
                  fontSize: isSelected ? 14.0 : 12.0,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF004283),
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
    }
    return const UserListScreen();
  }
}
