import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../core/network/api_client.dart';
import '../../patient_dashboard/views/patient_home_page.dart';

class AuthController {
  static const _storage = FlutterSecureStorage();

  static Future<void> loginWithPhone(BuildContext context, String phone) async {
    final String formattedPhone = '+964${phone.trim()}';
    final response = await ApiClient.patientLogin(phone: formattedPhone);

    if (response != null && response.containsKey('patient_id')) {
      await _saveSessionAndNavigate(
        context: context,
        id: response['patient_id'],
        role: 'PATIENT',
        name: response['full_name'],
      );
    } else {
      _showError(context, 'Patient record not found. Please register at the pharmacy.');
    }
  }

  static Future<void> loginAdmin(BuildContext context, String username, String password) async {
    final response = await ApiClient.adminLogin(username: username, password: password);

    if (response != null && response.containsKey('staff_id')) {
      await _saveSessionAndNavigate(
        context: context,
        id: response['staff_id'], // Standardized storage key
        role: response['role'],
        name: response['username'],
        isAdmin: true,
      );
    } else {
      _showError(context, 'Invalid staff credentials. Access denied.');
    }
  }

  /// Triggers native Facebook OAuth, retrieves profile, and syncs with MySQL
  static Future<void> loginWithFacebook(BuildContext context) async {
    try {
      // 1. Trigger Native Facebook Login Dialog
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // 2. Fetch the user's public profile data from Facebook
        final userData = await FacebookAuth.instance.getUserData();
        
        final String oauthId = userData['id'];
        final String fullName = userData['name'];
        final String? email = userData['email'];

        // 3. Send to our PHP backend to verify/register
        // (Note: We use ApiClient.patientLogin with an oauthId modifier, 
        // which you need to ensure routes to facebook_oauth.php in api_client.dart)
        final response = await ApiClient.facebookAuth(
          oauthId: oauthId,
          fullName: fullName,
          email: email,
        );

        if (response != null && response.containsKey('patient_id')) {
          await _saveSessionAndNavigate(
            context: context,
            id: response['patient_id'],
            role: 'PATIENT',
            name: response['full_name'],
          );
        } else {
          _showError(context, 'Failed to sync Facebook account with clinic database.');
        }
      } else if (result.status == LoginStatus.cancelled) {
        _showError(context, 'Facebook login cancelled by user.');
      } else {
        _showError(context, 'Facebook login failed: ${result.message}');
      }
    } catch (e) {
      _showError(context, 'An unexpected error occurred during OAuth.');
      print("Facebook Auth Error: $e");
    }
  }

  static Future<void> _saveSessionAndNavigate({
    required BuildContext context,
    required dynamic id,
    required String role,
    required String name,
    bool isAdmin = false,
  }) async {
    await _storage.write(key: 'session_patient_id', value: id.toString());
    await _storage.write(key: 'session_user_role', value: role);
    await _storage.write(key: 'session_full_name', value: name);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome, $name!'), backgroundColor: Colors.teal),
    );

    if (isAdmin) {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientHomePage(patientId: int.parse(id.toString()))),
      );
    }
  }

  static Future<Map<String, String?>> checkExistingSession() async {
    final patientId = await _storage.read(key: 'session_patient_id');
    final role = await _storage.read(key: 'session_user_role');
    return {'patient_id': patientId, 'role': role};
  }

  static Future<void> logout(BuildContext context) async {
    await _storage.deleteAll();
    // Also log out of the native Facebook session to clear cached tokens
    await FacebookAuth.instance.logOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }
}