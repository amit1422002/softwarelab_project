import 'dart:async'; // For Timer
import 'dart:convert'; // For jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:softwarelab/services/api_url.dart';
import 'ResetPasswordScreen.dart';

class EnterOTPScreen extends StatefulWidget {
  final String phoneNumber;

  EnterOTPScreen({required this.phoneNumber});

  @override
  _EnterOTPScreenState createState() => _EnterOTPScreenState();
}

class _EnterOTPScreenState extends State<EnterOTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
 
  @override
  void initState() {
    super.initState();
     
  }

  @override
  void dispose() { 
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
 

  void _verifyOTP() async {
    if (_otpController.text.length != 5) {
      _showErrorDialog("Please enter the complete 5-digit OTP.");
      return;
    }

    final response = await http.post(
      Uri.parse('${API_URL}/user/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phoneNumber': widget.phoneNumber,
        'otp': _otpController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['status'] == 'SUCCESS') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              phoneNumber: widget.phoneNumber,
              otp: _otpController.text,
            ),
          ),
        );
      } else {
        _showErrorDialog(responseBody['msg']); // Handle invalid OTP
      }
    } else {
      _showErrorDialog("Server error. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
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
                'Verify OTP',
                style: TextStyle(
                  fontSize: 24,
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
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(_focusNode);
                },
                child: AbsorbPointer(
                  absorbing: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: _otpController.text.length == index
                                ? Colors.blue
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _otpController.text.length > index
                                ? _otpController.text[index]
                                : '',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: 1),
              TextField(
                controller: _otpController,
                focusNode: _focusNode,
                maxLength: 5,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {}); // To update visual boxes when typing
                },
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                ),
                style: TextStyle(color: Colors.transparent, height: 0),
                showCursor: false, // Prevents cursor from showing in transparent text field
              ),
              ElevatedButton(
                onPressed: _verifyOTP ,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFe07c62),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Submit',
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
