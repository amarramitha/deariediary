import 'package:deariediary/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX for navigation and state management
import 'package:deariediary/register.dart'; // Register page import
import 'controller/login_controller.dart'; // Import the LoginController

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Bind the LoginController to the widget using GetX
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      body: Container(
        // Set the background color to pink
        decoration: BoxDecoration(
          color: Colors.pink[100], // Light pink background
        ),
        child: SingleChildScrollView(
          // Add this widget to enable scrolling
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'images/logo.jpg', // Add your logo image in the assets folder
                    height: 100, // You can adjust the size of the logo
                  ),
                  SizedBox(
                      height: 32), // Space between the logo and input fields

                  // Email TextField
                  TextField(
                    onChanged: (value) {
                      controller.email.value =
                          value; // Update observable email value
                    },
                    decoration: InputDecoration(
                      labelText: "Email",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Password TextField
                  TextField(
                    onChanged: (value) {
                      controller.password.value =
                          value; // Update observable password value
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),

                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      controller.login(); // Call login function from controller
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 228, 137, 167), // Button color
                      minimumSize:
                          Size(double.infinity, 50), // Full width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white, // Set the text color to white
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Add some spacing

                  // Navigate to Register Page
                  Text("Belum punya akun?"),
                  TextButton(
                    onPressed: () {
                      // Use GetX navigation to go to the Register page
                      Get.to(() => Register());
                    },
                    child: Text("Daftar Sekarang"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
