import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../patient_dashboard/views/patient_home_page.dart';

class AuthController {
  
  /// Handles the phone number login process
  static Future<void> loginWithPhone(BuildContext context, String phone) async {
    // 1. Format the phone number to match the KRI standard we set up
    final String formattedPhone = '+964${phone.trim()}';

    // 2. Send the request to our PHP API
    final response = await ApiClient.patientLogin(phone: formattedPhone);

    // 3. Handle the response
    if (response != null && response.containsKey('patient_id')) {
      final int patientId = response['patient_id'];
      final String fullName = response['full_name'];

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, $fullName!'),
          backgroundColor: Colors.teal,
        ),
      );

      // Navigate the patient to their dashboard and prevent them from going back to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PatientHomePage(patientId: patientId),
        ),
      );
    } else {
      // Show error message if the phone number isn't in the database
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient record not found. Please register at the pharmacy.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// Handles the Facebook OAuth login process (Placeholder for now)
  static Future<void> loginWithFacebook(BuildContext context) async {
    // We will implement the flutter_facebook_auth package logic here later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook login integration pending.')),
    );
  }
}