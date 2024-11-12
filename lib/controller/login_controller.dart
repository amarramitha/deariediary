import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deariediary/diary/dashboard_diary.dart';
import 'package:deariediary/routes/routes.dart'; // Import your routes file

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var email = ''.obs; // Observable variables for email and password
  var password = ''.obs;

  // Function to login
  Future<void> login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      // Save login status in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true); // Save login status

      // Navigate to Dashboard after successful login
      Get.offAllNamed(AppRoutes.home); // Use GetX navigation to go to home page
    } catch (e) {
      print("Error: $e");
      // Handle login error, could show a Snackbar or dialog if needed
    }
  }
}
