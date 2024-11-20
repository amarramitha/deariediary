import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deariediary/routes/routes.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'file_upload_controller.dart';

final firebase_storage.FirebaseStorage _storage =
    firebase_storage.FirebaseStorage.instanceFor(
  bucket:
      'gs://deariediary-b53a4.firebasestorage.app', // Replace with your custom bucket URL
);

class DiaryController extends GetxController {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FileUploadController _fileUploadController = FileUploadController();

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  File? imageFile;
  String? selectedMood;
  DateTime? date;

  var diaryEntries = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    fetchDiaryEntries(); // Load diary entries when the page is ready
  }

  firebase_auth.User? get currentUser => _auth.currentUser;

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
            'image': data['image'],
            'audio': data['audio'],
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

  // Upload a file (image or audio) to Firebase Storage
  Future<Map<String, String?>> _uploadFiles({
    File? image,
    String? audioFilePath,
  }) async {
    Map<String, String?> fileUrls = {};

    if (image != null) {
      fileUrls['image'] = await _uploadFile(
        image,
        'images/${currentUser!.uid}/diary_images/${DateTime.now().millisecondsSinceEpoch}.png',
      );
    }

    if (audioFilePath != null) {
      fileUrls['audio'] = await _uploadFile(
        File(audioFilePath),
        'audio/${currentUser!.uid}/diary_audio/${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
    }

    return fileUrls;
  }

  Future<String?> _uploadFile(File file, String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      final uploadTask = ref.putFile(file);
      await uploadTask.whenComplete(() => null); // Wait for upload to complete
      return await ref.getDownloadURL();
    } catch (e) {
      print("File upload error: $e");
      Get.snackbar("Upload Error", "Failed to upload file: $e",
          snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  // Method to add a new diary entry
  Future<void> addDiaryEntry(
    BuildContext context, {
    required String title,
    required String content,
    required String mood,
    File? image,
    String? audioFilePath,
    DateTime? date,
    String? imageUrl,
  }) async {
    await saveDiaryEntry(
      title: title,
      content: content,
      mood: mood,
      image: image,
      audioFilePath: audioFilePath,
      date: date ?? DateTime.now(), // Use current date if null
    );
    await fetchDiaryEntries(); // Refresh diary entries after adding
  }

  // Method to update an existing diary entry
  Future<void> updateDiaryEntry({
    required String entryId,
    required String title,
    required String content,
    required String mood,
    File? image,
    String? audioFilePath,
    required DateTime date,
    required BuildContext context,
    required String imageUrl,
  }) async {
    await saveDiaryEntry(
      entryId: entryId,
      title: title,
      content: content,
      mood: mood,
      image: image,
      audioFilePath: audioFilePath,
      date: date,
    );
    await fetchDiaryEntries(); // Refresh diary entries after update
  }

  // Save or update diary entry
  Future<void> saveDiaryEntry({
    String? entryId,
    required String title,
    required String content,
    String? mood,
    File? image,
    String? audioFilePath,
    required DateTime date,
  }) async {
    if (currentUser == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final fileUrls =
          await _uploadFiles(image: image, audioFilePath: audioFilePath);

      final entryData = {
        'title': title,
        'content': content,
        'mood': mood,
        'image': fileUrls['image'], // Image URL
        'audio': fileUrls['audio'], // Audio URL
        'timestamp': FieldValue.serverTimestamp(),
        'date': date, // Store original date
      };

      final diaryCollection = _db
          .collection('users')
          .doc(currentUser!.uid)
          .collection('diary_entries');

      if (entryId == null) {
        // Add new entry
        await diaryCollection.add(entryData);
      } else {
        // Update existing entry
        await diaryCollection.doc(entryId).update(entryData);
      }

      Get.snackbar("Success", "Diary entry saved successfully!");
      Get.offAllNamed(AppRoutes.home); // Navigate to home after saving
    } catch (e) {
      print("Error saving diary entry: $e");
      Get.snackbar("Error", "Failed to save diary entry: $e");
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
      await fetchDiaryEntries(); // Refresh entries after deletion
      Get.offAllNamed(AppRoutes.home); // Navigate to home after deletion
    } catch (e) {
      print("Error deleting diary entry: $e");
      Get.snackbar("Error", "Failed to delete diary entry");
    }
  }
}
