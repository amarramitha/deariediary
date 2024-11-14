import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FileUploadController {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseStorage get storage => _storage;

  // Function to upload a file and return the download URL
  Future<String?> uploadFile(File file, String path) async {
    try {
      // Reference to Firebase Storage at the provided path
      final ref = _storage
          .ref()
          .child(path); // Use _storage directly to reference Firebase Storage
      final uploadTask =
          ref.putFile(file); // Upload the file to Firebase Storage
      await uploadTask.whenComplete(() => null); // Wait for upload to complete

      // Get and return the download URL
      return await ref.getDownloadURL();
    } catch (e) {
      print("File upload error: $e");
      return null;
    }
  }
}
