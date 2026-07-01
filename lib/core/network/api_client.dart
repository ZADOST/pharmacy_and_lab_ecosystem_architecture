import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/inventory_admin/models/drug_model.dart';

class ApiClient {
  // If testing on a physical Android device, use your computer's local IP address (e.g., 192.168.1.x)
  // If testing on Web or Desktop emulator, 127.0.0.1 or localhost works.
  static const String baseUrl = "http://127.0.0.1/pharma_api/api";

  /// Sends a new drug object to the PHP backend to be stored in MySQL
  static Future<bool> addDrug(DrugModel drug) async {
    final Uri url = Uri.parse("$baseUrl/add_drug.php");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        // Convert the Dart object to JSON to send to PHP
        body: jsonEncode(drug.toJson()),
      );

      if (response.statusCode == 201) {
        print("Success: ${response.body}");
        return true;
      } else {
        print("Failed to add drug. Status Code: ${response.statusCode}");
        print("Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Network Error while adding drug: $e");
      return false;
    }
  }
  /// Sends login credentials to the PHP backend
  static Future<Map<String, dynamic>?> patientLogin({String? phone, String? oauthId}) async {
    final Uri url = Uri.parse("$baseUrl/patient_login.php");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          if (phone != null) "phone": phone,
          if (oauthId != null) "oauth_id": oauthId,
        }),
      );

      if (response.statusCode == 200) {
        // Successful login, return the patient data (ID and Name)
        return jsonDecode(response.body);
      } else {
        // Failed login (e.g., user not found)
        print("Login failed. Status Code: ${response.statusCode}");
        print("Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Network Error during login: $e");
      return null;
    }
  }
  /// Fetches drug details using the scanned QR hash
  static Future<DrugModel?> getDrugByQr(String qrHash) async {
    final Uri url = Uri.parse("$baseUrl/get_drug_by_qr.php?qr_hash=$qrHash");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return DrugModel.fromJson(jsonDecode(response.body));
      } else {
        return null; // Not found or error
      }
    } catch (e) {
      print("Network Error fetching drug: $e");
      return null;
    }
  }
  /// Fetches the monthly sales percentage breakdown
  static Future<List<Map<String, dynamic>>> getMonthlyAnalytics() async {
    final Uri url = Uri.parse("$baseUrl/get_sales_analytics.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['data'] != null) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print("Network Error fetching analytics: $e");
      return [];
    }
  }

  /// Submits the completed sale to the database
  static Future<bool> processSale({
    required int drugId,
    int? patientId,
    required int quantity,
    required double totalPrice,
  }) async {
    final Uri url = Uri.parse("$baseUrl/process_sale.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "drug_id": drugId,
          "patient_id": patientId,
          "quantity": quantity,
          "total_price": totalPrice,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Network Error processing sale: $e");
      return false;
    }
  }

  /// Example method to fetch all drugs (Requires get_drugs.php endpoint)
  static Future<List<DrugModel>> getAllDrugs() async {
    final Uri url = Uri.parse("$baseUrl/get_drugs.php");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body)['records'];
        return jsonList.map((json) => DrugModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load inventory");
      }
    } catch (e) {
      print("Network Error while fetching drugs: $e");
      return [];
    }
  }
  /// Registers a new walk-in patient into the database
  static Future<Map<String, dynamic>> registerPatient({
    required String fullName,
    required String phone,
    String? email,
  }) async {
    final Uri url = Uri.parse("$baseUrl/register_patient.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": fullName,
          "phone": phone,
          "email": email,
        }),
      );

      return {
        "success": response.statusCode == 201,
        "data": jsonDecode(response.body),
      };
    } catch (e) {
      print("Network Error registering patient: $e");
      return {"success": false, "data": {"message": "Network connection error"}};
    }
  }
  /// Fetches all active and historical lab tests for the admin dashboard
  static Future<List<Map<String, dynamic>>> getAllLabTests() async {
    final Uri url = Uri.parse("$baseUrl/get_all_lab_tests.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['data'] != null) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print("Network Error fetching lab tests: $e");
      return [];
    }
  }

  /// Assigns a new lab test to a specific patient
  static Future<bool> createLabTest({required int patientId, required String testName}) async {
    final Uri url = Uri.parse("$baseUrl/create_lab_test.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "patient_id": patientId,
          "test_name": testName,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Network Error creating lab test: $e");
      return false;
    }
  }

  /// Updates the status of an existing lab test (PENDING -> PROCESSING -> COMPLETED)
  static Future<bool> updateLabStatus({required int testId, required String status, String? resultData}) async {
    final Uri url = Uri.parse("$baseUrl/update_lab_status.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "test_id": testId,
          "status": status,
          if (resultData != null) "result_data": resultData,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Network Error updating lab status: $e");
      return false;
    }
  }
}