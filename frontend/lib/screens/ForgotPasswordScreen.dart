import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:softwarelab/services/api_url.dart';
import 'dart:convert'; // For jsonEncode
import 'EnterOTPScreen.dart'; // Ensure you have this screen created.

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false; // To show loading state

  // Function to send OTP
  void _sendOTP() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // API request
    try {
      final response = await http.post(
        Uri.parse('${API_URL}/user/forgot-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'phoneNumber': _phoneController.text}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final status = responseBody['status'];

        if (status == 'SUCCESS') {
          // Navigate to OTP screen if OTP is sent successfully
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EnterOTPScreen(phoneNumber: _phoneController.text),
            ),
          );
        } else {
          // Show error message if OTP not sent or any other issue
          _showErrorDialog(responseBody['msg']);
        }
      } else {
        // Handle other status codes
        print('Failed to send OTP. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        _showErrorDialog('Failed to send OTP. Please try again.');
      }
    } catch (e) {
      print('Error sending OTP: $e');
      _showErrorDialog('An error occurred. Please check your connection.');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Helper function to show error dialogs
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'FarmerEats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 80),
              Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Add login navigation logic if needed
                },
                child: Row(
                  children: [
                    Text(
                      'Remember your password?',
                      style: TextStyle(
                        color:  Colors.grey,
                      ),
                    ),
                     Text(
                      ' Login',
                      style: TextStyle(
                        color:  Color(0xFFe07c62),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
  controller: _phoneController,
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.phone),
    hintText: 'Phone Number',
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
  ),
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly, // This line restricts input to numbers only
  ],
),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFe07c62), // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        minimumSize: Size(double.infinity, 50), // Full-width button
                      ),
                      child: Text(
                        'Send Code',
                        style: TextStyle(fontSize: 16,color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
