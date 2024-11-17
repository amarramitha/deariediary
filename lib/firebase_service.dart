import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Initialize Firebase
  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Fungsi untuk mendapatkan mood berdasarkan tanggal
  Future<String?> getMoodByDate(DateTime date) async {
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    DocumentSnapshot docSnapshot = await _db.collection('diary_entries').doc(dateString).get();
    if (docSnapshot.exists) {
      return docSnapshot['mood'];
    }
    return null;
  }

  // Fungsi untuk menyimpan mood untuk tanggal tertentu
  Future<void> saveMood(DateTime date, String mood) async {
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    await _db.collection('diary_entries').doc(dateString).set({
      'mood': mood,
    });
  }
}
