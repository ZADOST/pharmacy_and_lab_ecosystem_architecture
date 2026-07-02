import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../patient_dashboard/views/patient_home_page.dart';

class AuthController {
  // Initialize the secure vault
  static const _storage = FlutterSecureStorage();

  /// Handles the phone number login process and saves the session securely
  static Future<void> loginWithPhone(BuildContext context, String phone) async {
    final String formattedPhone = '+964${phone.trim()}';
    final response = await ApiClient.patientLogin(phone: formattedPhone);

    if (response != null && response.containsKey('patient_id')) {
      final int patientId = response['patient_id'];
      final String fullName = response['full_name'];

      // 1. Save the credentials securely to the device
      await _storage.write(key: 'session_patient_id', value: patientId.toString());
      await _storage.write(key: 'session_user_role', value: 'PATIENT');
      await _storage.write(key: 'session_full_name', value: fullName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back, $fullName!'), backgroundColor: Colors.teal),
      );

      // 2. Navigate to the dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientHomePage(patientId: patientId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient record not found. Please register at the pharmacy.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  /// Handles the staff login process and saves the session securely
  static Future<void> loginAdmin(BuildContext context, String username, String password) async {
    final response = await ApiClient.adminLogin(username: username, password: password);

    if (response != null && response.containsKey('staff_id')) {
      final String staffId = response['staff_id'].toString();
      final String role = response['role'];
      final String name = response['username'];

      // 1. Save the staff credentials securely to the device
      await _storage.write(key: 'session_patient_id', value: staffId); // Using same key for ease of checking
      await _storage.write(key: 'session_user_role', value: role);
      await _storage.write(key: 'session_full_name', value: name);

      // 2. Navigate straight to the Admin Dashboard
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid staff credentials. Access denied.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// Checks if a user is already logged in when the app starts
  static Future<Map<String, String?>> checkExistingSession() async {
    final patientId = await _storage.read(key: 'session_patient_id');
    final role = await _storage.read(key: 'session_user_role');
    
    return {
      'patient_id': patientId,
      'role': role,
    };
  }

  /// Clears the secure storage and logs the user out
  static Future<void> logout(BuildContext context) async {
    await _storage.deleteAll();
    Navigator.pushReplacementNamed(context, '/');
  }
}