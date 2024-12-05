import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DiaryController extends GetxController {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String? selectedMood;
  DateTime? date;

  var diaryEntries = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  firebase_auth.User? get currentUser => _auth.currentUser;

  @override
  void onReady() {
    super.onReady();
    fetchDiaryEntries(); // Load diary entries when the page is ready
  }

  // Fetch diary entries from Firestore
  Future<void> fetchDiaryEntries() async {
    if (currentUser != null) {
      isLoading.value = true;
      try {
        final snapshot = await _db
            .collection('users')
            .doc(currentUser!.uid)
            .collection('diary_entries')
            .orderBy('date', descending: true)
            .get();

        diaryEntries.value = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'],
            'content': data['content'],
            'mood': data['mood'],
            'date': (data['date'] as Timestamp).toDate(),
          };
        }).toList();
      } catch (e) {
        print("Error fetching diary entries: $e");
        Get.snackbar("Error", "Failed to fetch diary entries");
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Add a new diary entry
  Future<void> addDiaryEntry(
    BuildContext context, {
    required String title,
    required String content,
    required String mood,
    DateTime? date,
  }) async {
    if (currentUser == null) {
      Get.snackbar("Error", "User is not authenticated");
      return;
    }

    try {
      final entryData = {
        'title': title,
        'content': content,
        'mood': mood,
        'date': date ?? DateTime.now(), // Use current date if null
        'timestamp': FieldValue.serverTimestamp(),
      };

      final diaryCollection = _db
          .collection('users')
          .doc(currentUser!.uid)
          .collection('diary_entries');

      final newDoc = await diaryCollection.add(entryData);
      diaryEntries.insert(0, {'id': newDoc.id, ...entryData});

      Get.snackbar("Success", "Diary entry added successfully!");
    } catch (e) {
      print("Error adding diary entry: $e");
      Get.snackbar("Error", "Failed to add diary entry");
    }
  }

  // Update an existing diary entry
  Future<void> updateDiaryEntry(
    BuildContext context, {
    required String entryId,
    required String title,
    required String content,
    required String mood,
    DateTime? date,
  }) async {
    if (currentUser == null) {
      Get.snackbar("Error", "User is not authenticated");
      return;
    }

    try {
      final entryData = {
        'title': title,
        'content': content,
        'mood': mood,
        'date': date ?? DateTime.now(), // Gunakan tanggal sekarang jika null
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _db
          .collection('users')
          .doc(currentUser!.uid)
          .collection('diary_entries')
          .doc(entryId)
          .update(entryData); // Update entry di Firestore

      // Perbarui diaryEntries di lokal (untuk UI)
      final index = diaryEntries.indexWhere((entry) => entry['id'] == entryId);
      if (index != -1) {
        diaryEntries[index] = {'id': entryId, ...entryData};
      }

      Get.snackbar("Success", "Diary entry updated successfully!");
    } catch (e) {
      print("Error updating diary entry: $e");
      Get.snackbar("Error", "Failed to update diary entry");
    }
  }

  // Delete a diary entry
  Future<void> deleteDiaryEntry(String entryId) async {
    if (currentUser == null) {
      Get.snackbar("Error", "User is not authenticated");
      return;
    }

    try {
      await _db
          .collection('users')
          .doc(currentUser!.uid)
          .collection('diary_entries')
          .doc(entryId)
          .delete();

      diaryEntries.removeWhere((entry) => entry['id'] == entryId);
      Get.snackbar("Success", "Diary entry deleted successfully!");
      await fetchDiaryEntries();
    } catch (e) {
      print("Error deleting diary entry: $e");
      Get.snackbar("Error", "Failed to delete diary entry");
    }
  }
}
