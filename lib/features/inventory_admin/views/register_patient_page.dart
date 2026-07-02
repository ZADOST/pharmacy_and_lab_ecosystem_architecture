import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';

class RegisterPatientPage extends StatefulWidget {
  const RegisterPatientPage({Key? key}) : super(key: key);

  @override
  State<RegisterPatientPage> createState() => _RegisterPatientPageState();
}

class _RegisterPatientPageState extends State<RegisterPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;
  int? _newlyRegisteredId;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Enforce the KRI format explicitly on the backend data push
      final formattedPhone = '+964${_phoneController.text.trim()}';

      final result = await ApiClient.registerPatient(
        fullName: _nameController.text.trim(),
        phone: formattedPhone,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      );

      // 1. BUG FIX: The 'mounted' check prevents crashes if the user closes the page while loading
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result['success']) {
        setState(() {
          _newlyRegisteredId = result['data']['patient_id'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'), 
            backgroundColor: AppColors.successGreen,
          ),
        );
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['data']['message'] ?? 'Failed to register'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_newlyRegisteredId != null)
              Container(
                // 2. BUG FIX: Replaced .bottom with .only(bottom: 24)
                margin: const EdgeInsets.only(bottom: 24.0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // 3. BUG FIX: Replaced deprecated .withOpacity with .withValues(alpha:)
                  color: AppColors.successGreen.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.successGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.successGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Success! The new Patient ID is: $_newlyRegisteredId\nYou can now use this ID for the POS and Lab assignments.',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Patient Profile',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Legal Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value!.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '750 123 4567',
                          border: OutlineInputBorder(),
                          prefixText: '+964 ',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) => value!.isEmpty || value.length < 10 ? 'Valid phone number required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitRegistration,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Register Patient to Database', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}