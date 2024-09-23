import 'package:flutter/material.dart';
import 'package:softwarelab/screens/login_screen.dart';

import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'image': 'assets/images/bg1.png',
      'title': 'Quality',
      'description':
          'Sell your farm fresh products directly to consumers, cutting out the middleman and reducing emissions of the global supply chain.',
      'buttonText': 'Join the movement!',
      'bgColor': Colors.green, // First page background color
      'buttonColor': Colors.green, // First page button color
    },
    {
      'image': 'assets/images/bg2.png',
      'title': 'Convenient',
      'description':
          'Our team of delivery drivers will make sure your orders are picked up on time and promptly delivered to your customers.',
      'buttonText': 'Join the movement!',
      'bgColor': Colors.orange, // Second page background color
      'buttonColor': Colors.deepOrangeAccent, // Second page button color
    },
    {
      'image': 'assets/images/bg3.png',
      'title': 'Local',
      'description':
          'We love the earth and know you do too! Join us in reducing our local carbon footprint one order at a\n time.',
      'buttonText': 'Join the movement!',
      'bgColor': Colors.amber, // Third page background color
      'buttonColor': Colors.amber, // Third page button color
    },
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: _pages[_currentPage]['bgColor'], // Apply background color here
      body: Stack(
        children: [
          // PageView to enable swiping between pages
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Column(
                children: [
                  // Top half with image
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(
                          top: mediaQuery.size.height * 0.1),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          _pages[index]['image']!, // Display the image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Empty space
                  SizedBox(height: mediaQuery.size.height * 0.1), // Add space for the bottom container
                ],
              );
            },
          ),

          // Bottom half container that appears above the background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: mediaQuery.size.height * 0.44,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(mediaQuery.size.height * 0.02),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title (e.g. Quality, Convenient, etc.)
                  Text(
                    _pages[_currentPage]['title']!,
                    style: TextStyle(
                      fontSize: mediaQuery.size.height * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: mediaQuery.size.height * 0.03),
                  // Description Text
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        _pages[_currentPage]['description']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: mediaQuery.size.height * 0.02,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: mediaQuery.size.height * 0.03),
                  // Page indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      return _currentPage == index
                          ? Container(
                              width: mediaQuery.size.width * 0.05, // Width of the horizontal bar
                              height:  10,
                              // Height of the horizontal bar
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: CircleAvatar(
                                radius: mediaQuery.size.height * 0.005,
                                backgroundColor: Color(0xFF261C12),
                              ),
                            );
                    }),
                  ),

                 SizedBox(height: mediaQuery.size.height * 0.05),
                  // Join Button with changing color
                  Container(
                    height: 60,
                    width: 235,
                    // padding: EdgeInsets.symmetric(vertical: mediaQuery.size.height * 0.015),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: _pages[_currentPage]['buttonColor'], // Change button color based on page
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                      },
                      child: Text(
                        _pages[_currentPage]['buttonText']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: mediaQuery.size.height * 0.02, color: Colors.white),
                      ),
                    ),
                  ),
                  // Login Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: mediaQuery.size.height * 0.02,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

