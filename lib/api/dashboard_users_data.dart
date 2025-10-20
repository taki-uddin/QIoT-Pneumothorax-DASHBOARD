import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pneumothoraxdashboard/constants/api_constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pneumothoraxdashboard/helpers/session_storage_helpers.dart';
import 'package:pneumothoraxdashboard/main.dart';

class DashboardUsersData {
  static Future<Map<String, dynamic>?> getAllUsersData() async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request =
        http.Request('GET', Uri.parse('${ApiConstants.baseURL}/admin/'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserByIdData(String userId) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request =
        http.Request('GET', Uri.parse('${ApiConstants.baseURL}/admin/$userId'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getDrainageRateHistories(String userId,
      int startmonth, int startyear, int endmonth, int endyear) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/drainageratehistory/$userId?startmonth=$startmonth&startyear=$startyear&endmonth=$endmonth&endyear=$endyear'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getRespiratoryRateHistories(
      String userId, int month, int year) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/respiratoryratehistory/$userId?month=$month&year=$year'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAllImages(String userId) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET', Uri.parse('${ApiConstants.baseURL}/admin/image/$userId'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      logger.d('responsecode: ${response.statusCode}');
      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAllNotes(String userId) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET', Uri.parse('${ApiConstants.baseURL}/admin/$userId/notes'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      logger.d('responsecode: ${response.statusCode}');
      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadUsersAsthmaActionPlan(
    dynamic file,
    String userId,
  ) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/uploadasthmaactionplan/$userId'));

    // Read file bytes
    List<int> fileBytes;
    if (kIsWeb) {
      // For web platform, file should already be bytes from FilePicker
      fileBytes = file.bytes;
    } else {
      // For mobile platforms, file should already be bytes
      fileBytes = file.bytes;
    }

    // Add the file to the request
    request.files.add(
      http.MultipartFile.fromBytes(
        'file', // The name of the field expected by the server
        fileBytes, // The file bytes
        filename: file.name, // The file name
      ),
    );

    // Add headers to the request
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadEducationalPlan(
    dynamic file,
  ) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.MultipartRequest('POST',
        Uri.parse('${ApiConstants.baseURL}/admin/uploadeducationalplan'));

    // Read file bytes
    List<int> fileBytes;
    if (kIsWeb) {
      // For web platform, file should already be bytes from FilePicker
      fileBytes = file.bytes;
    } else {
      // For mobile platforms, file should already be bytes
      fileBytes = file.bytes;
    }

    // Add the file to the request
    request.files.add(
      http.MultipartFile.fromBytes(
        'file', // The name of the field expected by the server
        fileBytes, // The file bytes
        filename: file.name, // The file name
      ),
    );

    // Add headers to the request
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateUsers(
      String userId, Map<String, dynamic> updates) async {
    logger.d('updates: $updates');
    logger.d('userId: $userId');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'PUT', Uri.parse('${ApiConstants.baseURL}/admin/update/$userId'));
    request.headers.addAll(headers);
    request.body = json.encode(updates); // Encoding the updates as a JSON body
    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          logger.d('jsonResponse: $jsonResponse');
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }
}
