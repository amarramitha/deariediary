import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:deariediary/diary/dashboard_diary.dart';
import 'package:deariediary/login.dart';
import 'package:deariediary/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart'; // Pastikan ini diimpor dengan benar
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart'; // Import GetX
import 'routes/routes.dart'; // Import routes file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Inisialisasi Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dearie Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash', // Mulai dengan splash screen route
      getPages: AppRoutes.routes, // Tentukan routes di sini
    );
  }
}
