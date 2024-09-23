import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:softwarelab/screens/auth.dart';
import 'package:softwarelab/services/api_url.dart';
import 'dart:convert';
import 'confirmation_screen.dart';
import 'login_screen.dart';
import 'dart:async';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int currentPage = 1;
  final int totalPages = 4;
  String? selectedFileName;
  bool isSubmitting = false;

  // Form controllers
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController informalNameController = TextEditingController();
  TextEditingController streetAddressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();

  Map<String, List<String>> selectedTimes = {
    'M': [],
    'T': [],
    'W': [],
    'Th': [],
    'F': [],
    'S': [],
    'Su': [],
  };

  String selectedDay = 'M';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("FarmerEats"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Signup $currentPage of $totalPages",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    if (currentPage == 1) buildWelcomePage(),
                    if (currentPage == 2) buildFarmInfoPage(),
                    if (currentPage == 3) buildVerificationPage(),
                    if (currentPage == 4) buildBusinessHoursPage(),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: buildNavigationInfo(),
          ),
        ],
      ),
    );
  }

  Widget buildNavigationInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        currentPage == 1
            ? GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: isSubmitting ? null : () {
                  if (currentPage > 1) {
                    setState(() {
                      currentPage--;
                    });
                  }
                },
              ),
        Container(
          height: 50,
          width: 200,
          decoration: BoxDecoration(
            color: Color(0xFFe07c62),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextButton(
            onPressed: () {
              if (validateCurrentPage()) {
                if (currentPage < totalPages) {
                  setState(() {
                    currentPage++;
                  });
                } else {
                  submitForm(); // Submit when on last page
                }
              }
            },
            child: isSubmitting
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    currentPage == totalPages ? "Signup" : "Continue",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  bool validateCurrentPage() {
    if (currentPage == 1) {
      return validateWelcomePage();
    } else if (currentPage == 2) {
      return validateFarmInfoPage();
    } else if (currentPage == 3) {
      return validateVerificationPage();
    } else if (currentPage == 4) {
      return validateBusinessHoursPage();
    }
    return true;
  }

  bool validateWelcomePage() {
    if (fullNameController.text.isEmpty) {
      showError("Full Name cannot be empty");
      return false;
    }
    if (emailController.text.isEmpty || !isValidEmail(emailController.text)) {
      showError("Please enter a valid email");
      return false;
    }
    if (phoneController.text.isEmpty || !isNumeric(phoneController.text)) {
      showError("Phone number must be numeric");
      return false;
    }
    if (passwordController.text.isEmpty ||
        passwordController.text != rePasswordController.text) {
      showError("Passwords do not match");
      return false;
    }
    return true;
  }

  bool validateFarmInfoPage() {
    if (businessNameController.text.isEmpty) {
      showError("Business Name cannot be empty");
      return false;
    }
    if (informalNameController.text.isEmpty) {
      showError("Informal Name cannot be empty");
      return false;
    }
    if (streetAddressController.text.isEmpty ||
        cityController.text.isEmpty ||
        stateController.text.isEmpty ||
        zipCodeController.text.isEmpty ||
        !isNumeric(zipCodeController.text)) {
      showError("Please fill out the complete address with a numeric zip code");
      return false;
    }
    return true;
  }

  bool validateVerificationPage() {
    if (selectedFileName == null) {
      showError("Please attach the proof of registration");
      return false;
    }
    return true;
  }

  bool validateBusinessHoursPage() {
    if (selectedTimes.values.every((times) => times.isEmpty)) {
      showError("Please select at least one business hour");
      return false;
    }
    return true;
  }

  Future<void> submitForm() async {
    setState(() {
      isSubmitting = true;
    });

    final userData = {
      "fullName": fullNameController.text,
      "email": emailController.text,
      "phoneNumber": phoneController.text,
      "password": passwordController.text,
      "businessName": businessNameController.text,
      "informalName": informalNameController.text,
      "streetAddress": streetAddressController.text,
      "city": cityController.text,
      "state": stateController.text,
      "zipCode": zipCodeController.text,
      "registrationProof": selectedFileName,
      "businessHours": jsonEncode(selectedTimes),
    };

    final response = await http.post(
      Uri.parse("${API_URL}/user/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    setState(() {
      isSubmitting = false;
    });

    if (response.statusCode == 200) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ConfirmationScreen()),
        (Route<dynamic> route) => false, // Prevent going back after submission
      );
    } else {
      showError("Signup failed. Please try again.");
    }
  }

  Widget buildWelcomePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 30),
         Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    signInWithGoogle();
                  },
                  child: Container(
                    width: 65,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 5),
                          blurRadius: 10.0,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/google.png'),
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    signInWithApple();
                  },
                  child: Container(
                    width: 65,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 5),
                          blurRadius: 10.0,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/apple.png'),
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    // signInWithFacebook();
                  },
                  child: Container(
                    width: 65,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 5),
                          blurRadius: 10.0,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/facebook.png'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
        Center(
          child: Text(
            "or signup with",
             style: TextStyle(color: Colors.grey),
          ),
        ),
        SizedBox(height: 15,),
        buildTextField("Full Name", Icons.person, fullNameController),
        buildTextField("Email Address", Icons.alternate_email, emailController),
        buildTextField("Phone Number", Icons.phone, phoneController),
        buildTextField("Password", Icons.lock, passwordController,
            isObscure: true),
        buildTextField("Re-enter Password", Icons.lock, rePasswordController,
            isObscure: true),
      ],
    );
  }

  Widget buildFarmInfoPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Farm Info",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 30),
        buildTextField("Business Name", Icons.label, businessNameController),
        buildTextField("Informal Name", Icons.tag, informalNameController),
        buildTextField("Street Address", Icons.home, streetAddressController),
        buildTextField("City", Icons.location_city, cityController),
        Row(
          children: [
            Expanded(
              child: buildTextField("State", Icons.map, stateController),
            ),
            SizedBox(width: 10),
            Expanded(
              child: buildTextField(
                "Zip Code",
                Icons.location_on,
                zipCodeController,
                isNumericInput: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildVerificationPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Verification",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "Attach proof of Department of Agriculture registrations i.e. Florida Fresh, USDA Approved, USDA Organic",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedFileName ?? "Attach proof of registration",
              style: TextStyle(color: Colors.grey),
            ),
            IconButton(
              icon: Icon(Icons.camera_alt, color: Color(0xFFe07c62)),
              onPressed: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.any);
                if (result != null) {
                  setState(() {
                    selectedFileName = result.files.single.name;
                  });
                }
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        if (selectedFileName != null)
          Text(
            "Selected file: $selectedFileName",
            style: TextStyle(color: Colors.black),
          ),
      ],
    );
  }

  Widget buildBusinessHoursPage() {
    List<String> timeSlots = [
      '8:00am - 10:00am',
      '10:00am - 1:00pm',
      '1:00pm - 4:00pm',
      '4:00pm - 7:00pm',
      '7:00pm - 10:00pm'
    ];

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Business Hours",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Choose the hours your farm is open for pickups.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['M', 'T', 'W', 'Th', 'F', 'S', 'Su']
                  .map((day) => ChoiceChip(
                        label: Text(day),
                        selected: selectedDay == day,
                        selectedColor: Color(0xFFe07c62),
                        onSelected: (bool selected) {
                          setState(() {
                            selectedDay = day;
                          });
                        },
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: timeSlots
                  .map((timeSlot) => FilterChip(
                        label: Text(timeSlot),
                        selected: selectedTimes[selectedDay]
                                ?.contains(timeSlot) ??
                            false,
                        selectedColor: Color(0xFFe07c62),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              selectedTimes[selectedDay]?.add(timeSlot);
                            } else {
                              selectedTimes[selectedDay]?.remove(timeSlot);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextField(String labelText, IconData icon,
      TextEditingController controller,
      {bool isObscure = false, bool isNumericInput = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType:
            isNumericInput ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
          ),
            filled: true,
                fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  bool isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
