import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:deariediary/diary/dashboard_diary.dart';
import 'package:deariediary/login.dart'; // Pastikan untuk mengimpor halaman Login
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay untuk splash screen
    Future.delayed(Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn =
          prefs.getBool('isLoggedIn') ?? false; // Ambil status login

      if (isLoggedIn) {
        // Jika sudah login, arahkan ke DashboardDiary
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardDiary()),
        );
      } else {
        // Jika belum login, arahkan ke halaman Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/logo.jpg',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'Dearie Diary',
              style: TextStyle(
                fontFamily: 'Marck',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(
                    255, 218, 96, 136), // Set the text color to pink
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.white, // White shadow color
                    offset: Offset(2.0, 2.0), // Position of the shadow
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
