import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deariediary/routes/routes.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables for email and password
  var email = ''.obs;
  var password = ''.obs;

  // Function to handle login
  Future<void> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar(
        'Login Failed',
        'Please enter both email and password.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[200],
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Attempt to sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      // Retrieve the user's name if available
      String userName = userCredential.user?.displayName ?? 'User';

      // Save login status in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Display a success notification
      Get.snackbar(
        'Login Success',
        'Welcome, $userName!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue[200],
        colorText: Colors.white,
      );

      // Navigate to the home page after successful login
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      // Display an error notification on login failure
      Get.snackbar(
        'Login Error',
        'Incorrect email or password',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Error: $e");
    }
  }
}
