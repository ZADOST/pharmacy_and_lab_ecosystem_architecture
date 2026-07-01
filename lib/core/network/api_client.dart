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
}