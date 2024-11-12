import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deariediary/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DiaryController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
    fetchDiaryEntries(); // Load entries when the page is ready
  }

  User? get currentUser => _auth.currentUser;

  // Fetch diary entries from Firestore
  Future<void> fetchDiaryEntries() async {
    if (currentUser != null) {
      isLoading.value = true;
      try {
        final snapshot = await _db
            .collection('users')
            .doc(currentUser!.uid)
            .collection('diary_entries')
            .orderBy('date',
                descending: true) // Order by date instead of timestamp
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
            'date': (data['date'] as Timestamp)
                .toDate(), // Convert Timestamp to DateTime
          };
        }).toList();
      } catch (e) {
        print("Error fetching diary entries: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Upload a file (image or audio) to Firebase Storage
  Future<String?> _uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      await uploadTask.whenComplete(() => null);
      return await ref.getDownloadURL();
    } catch (e) {
      print("File upload error: $e");
      return null;
    }
  }

  // Upload image and audio files together and return their URLs
  Future<Map<String, String?>> _uploadFiles({
    File? image,
    String? audioFilePath,
  }) async {
    Map<String, String?> fileUrls = {};

    if (image != null) {
      fileUrls['image'] = await _uploadFile(image,
          'images/${currentUser!.uid}/diary_images/${DateTime.now().millisecondsSinceEpoch}');
    }

    if (audioFilePath != null) {
      fileUrls['audio'] = await _uploadFile(File(audioFilePath),
          'audio/${currentUser!.uid}/diary_audio/${DateTime.now().millisecondsSinceEpoch}');
    }

    return fileUrls;
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
  }) async {
    await saveDiaryEntry(
      title: title,
      content: content,
      mood: mood,
      image: image,
      audioFilePath: audioFilePath,
      date: date ?? DateTime.now(), // Use current date if null
      context: context,
    );
    await fetchDiaryEntries(); // Refresh diary entries after adding
  }

  // Method to update an existing diary entry
  Future<void> updateDiaryEntry(
      {required String entryId,
      required String title,
      required String content,
      required String mood,
      File? image,
      String? audioFilePath,
      required BuildContext context,
      required DateTime date}) async {
    await saveDiaryEntry(
      entryId: entryId,
      title: title,
      content: content,
      mood: mood,
      image: image,
      audioFilePath: audioFilePath,
      date: date ?? DateTime.now(),
      context: context,
    );
    await fetchDiaryEntries(); // Refresh diary entries after updating
  }

  // Save or update diary entry
  Future<void> saveDiaryEntry({
    String? entryId,
    required String title,
    required String content,
    String? mood,
    File? image,
    String? audioFilePath,
    required BuildContext context,
    required DateTime date,
  }) async {
    if (currentUser == null) {
      throw Exception('User  is not authenticated');
    }

    try {
      final fileUrls =
          await _uploadFiles(image: image, audioFilePath: audioFilePath);

      final entryData = {
        'title': title,
        'content': content,
        'mood': mood,
        'image': fileUrls['image'],
        'audio': fileUrls['audio'],
        'timestamp': FieldValue.serverTimestamp(),
        'date': date, // Save actual date
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
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar("Error", "Failed to save diary entry: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save diary entry: $e')));
    }
  }

  // Delete a diary entry
  Future<void> deleteDiaryEntry(BuildContext context, String entryId) async {
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
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      print("Error deleting diary entry: $e");
      Get.snackbar("Error", "Failed to delete diary entry");
    }
  }

  // Edit an existing diary entry
  Future<void> saveEditedDiaryEntry(String entryId) async {
    if (titleController.text.isEmpty ||
        contentController.text.isEmpty ||
        selectedMood == null) {
      Get.snackbar('Error', 'Title, content, and mood cannot be empty!');
      return;
    }

    isLoading.value = true;

    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadFile(imageFile!,
            'images/${currentUser!.uid}/diary_images/${DateTime.now().millisecondsSinceEpoch}');
      }

      await _db
          .collection('users')
          .doc(currentUser!.uid)
          .collection('diary_entries')
          .doc(entryId)
          .update({
        'title': titleController.text,
        'content': contentController.text,
        'mood': selectedMood,
        'image': imageUrl ?? '', // If no image, store an empty string
      });

      await fetchDiaryEntries(); // Refresh the list in DiaryPage
      Get.offNamed('home');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update diary entry: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
