import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pneumothoraxdashboard/api/dashboard_users_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'package:pneumothoraxdashboard/main.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> userData = [];
  List<dynamic> filteredUserData = [];
  List<bool> _rowEnabled = [];
  dynamic _selectedFile;
  int _hoverIndex = -1;
  // ignore: unused_field
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _getAllUsersData();
  }

  Future<void> uploadUserAAP(String userId) async {
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
        final Map<String, dynamic>? uploadUserAAP = await DashboardUsersData()
            .uploadUsersAsthmaActionPlan(_selectedFile!, userId);
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

  Future<void> _getAllUsersData() async {
    DashboardUsersData.getAllUsersData().then(
      (value) async {
        if (value != null) {
          setState(() {
            userData = List.from(
                value['payload'].reversed); // Reverse the order of userData
            filteredUserData =
                List.from(userData); // Initialize filteredUserData
            // Initialize the _rowEnabled list based on the status field
            _rowEnabled = userData.map<bool>((user) {
              // Assuming 'Enable' means enabled and others mean disabled
              return user['status'] == 'Enabled';
            }).toList();
          });
        } else {
          logger.d('Failed to get user data');
        }
      },
    );
  }

  Future<void> _enabledisableUsers(String userId, String newStatus) async {
    Map<String, dynamic> updates = {
      'status': newStatus, // Update status (Enabled or Disabled)
    };
    DashboardUsersData.updateUsers(userId, updates).then(
      (value) async {
        if (value != null) {
          logger.d('Value: $value');
        } else {
          logger.d('Failed to get user data');
        }
      },
    );
  }

  void _filterUserData(String query) {
    setState(() {
      _searchQuery = query;
      filteredUserData = userData.where((user) {
        // Check if the 'inhaler' field contains the query (case-insensitive)
        return user['_id']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Search Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: isMobile ? 12 : 16,
                    ),
                    child: TextField(
                      onChanged: _filterUserData,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search by User ID',
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 12 : 16,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF004283).withOpacity(0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Table Header (only show on web)
          if (!isMobile)
            Container(
              width: screenSize.width,
              height: 42,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF004283).withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      "User ID",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF004283),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Weight",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF004283),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Temperature",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF004283),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Heart Rate",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF004283),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Enable/Disable",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF004283),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // User List
          Expanded(
            child: ListView.builder(
              itemCount: filteredUserData.length,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 16,
                vertical: 4,
              ),
              itemBuilder: (BuildContext context, int index) {
                return isMobile
                    ? _buildMobileUserCard(context, index, screenSize)
                    : _buildWebUserRow(context, index, screenSize);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Mobile card-based layout
  Widget _buildMobileUserCard(
      BuildContext context, int index, Size screenSize) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/usersdetails/${filteredUserData[index]['_id']}',
          arguments: {'id': '${filteredUserData[index]['_id']}'},
        );
      },
      child: Container(
        width: screenSize.width,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF004283).withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User ID Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    filteredUserData[index]['_id'],
                    style: const TextStyle(
                      color: Color(0xFF004283),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: _rowEnabled[index],
                    onChanged: (newValue) async {
                      setState(() {
                        _rowEnabled[index] = newValue;
                      });
                      String newStatus = newValue ? 'Enabled' : 'Disabled';
                      await _enabledisableUsers(
                          filteredUserData[index]['_id'], newStatus);
                    },
                    activeColor: const Color(0xFF004283),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Patient Vitals in Grid
            Row(
              children: [
                Expanded(
                  child: _buildVitalItem(
                    'Weight',
                    '${filteredUserData[index]['weight']}',
                    Icons.monitor_weight_outlined,
                    const Color(0xFF27AE60),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalItem(
                    'Temp',
                    '${filteredUserData[index]['temperature']}',
                    Icons.thermostat_outlined,
                    const Color(0xFFFF8500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildVitalItem(
                    'Heart Rate',
                    '${filteredUserData[index]['heartRate']}',
                    Icons.favorite_outline,
                    const Color(0xFFFD4646),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF004283).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: const Color(0xFF004283).withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF004283).withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for vital signs in mobile card
  Widget _buildVitalItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Web table row layout (existing design)
  Widget _buildWebUserRow(BuildContext context, int index, Size screenSize) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/usersdetails/${filteredUserData[index]['_id']}',
          arguments: {'id': '${filteredUserData[index]['_id']}'},
        );
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _hoverIndex = index;
          });
        },
        onExit: (_) {
          setState(() {
            _hoverIndex = -1;
          });
        },
        child: Container(
          width: screenSize.width,
          height: 64,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hoverIndex == index
                ? const Color(0xFF004283).withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF004283).withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User ID
              Expanded(
                flex: 4,
                child: Text(
                  filteredUserData[index]['_id'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF004283),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              // Weight
              Expanded(
                flex: 2,
                child: Text(
                  '${filteredUserData[index]['weight']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              // Body Temperature
              Expanded(
                flex: 2,
                child: Text(
                  '${filteredUserData[index]['temperature']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              // Heart Rate
              Expanded(
                flex: 2,
                child: Text(
                  '${filteredUserData[index]['heartRate']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              // Enable/Disable
              Expanded(
                flex: 2,
                child: SizedBox(
                  width: screenSize.width * 0.1,
                  height: 8,
                  child: Center(
                    child: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: _rowEnabled[index],
                        onChanged: (newValue) async {
                          setState(() {
                            _rowEnabled[index] = newValue;
                          });
                          String newStatus = newValue ? 'Enabled' : 'Disabled';
                          await _enabledisableUsers(
                              filteredUserData[index]['_id'], newStatus);
                        },
                        activeColor: const Color(0xFF004283),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
