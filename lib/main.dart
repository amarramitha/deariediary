import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure this is imported
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart'; // Import GetX

import 'routes/routes.dart'; // Import routes file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore db = FirebaseFirestore.instance;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Change to GetMaterialApp for GetX support
      title: 'Dearie Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash', // Start with the splash screen route
      getPages: AppRoutes.routes, // Define your routes here
    );
  }
}
