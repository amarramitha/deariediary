import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mengambil profil pengguna dari Firestore dan FirebaseAuth
  Future<Map<String, String>> getProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? user.displayName ?? 'No name set',
          'photoUrl': data['photoUrl'] ?? user.photoURL ?? '',
        };
      } else {
        return {
          'name': user.displayName ?? 'No name set',
          'photoUrl': user.photoURL ?? '',
        };
      }
    } else {
      throw Exception('User not logged in');
    }
  }

  // Memilih gambar baru untuk foto profil
  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Mengupload gambar ke Firebase Storage dan mendapatkan URL-nya
  Future<String> uploadImage(File image) async {
    try {
      print("Uploading image: ${image.path}");
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_pictures")
          .child(fileName);

      UploadTask uploadTask = storageRef.putFile(image);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            "Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}");
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("File uploaded successfully. Download URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }

  // Mengupdate profil pengguna di FirebaseAuth dan Firestore
  Future<void> updateProfile(String name, String photoUrl) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateProfile(displayName: name, photoURL: photoUrl);
      await user.reload();
      user = _auth.currentUser;

      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'photoUrl': photoUrl,
      }, SetOptions(merge: true));
    } else {
      throw Exception('User not logged in');
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
