import 'dart:html' as html;
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:flutter/foundation.dart';  // Tambahkan impor ini
import 'package:flutter/material.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mengambil profil pengguna dari Firestore dan FirebaseAuth
  Future<Map<String, String>> getProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
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
    if (kIsWeb) {
      // Untuk platform web menggunakan image_picker_web
      final pickedFile = await ImagePickerWeb.getImageAsFile();
      if (pickedFile != null) {
        return File(pickedFile.name); // Menggunakan nama file untuk Web
      }
    } else {
      // Untuk platform Android/iOS menggunakan image_picker
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    }
    return null;
  }

  // Mengupload gambar ke Firebase Storage dan mendapatkan URL-nya
  Future<String> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_pictures")
          .child(fileName);

      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
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

  // Mengubah password pengguna
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Verifikasi password lama
        String email = user.email!;
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: oldPassword,
        );

        // Menyautentikasi dengan kredensial lama
        await user.reauthenticateWithCredential(credential);

        // Ganti password dengan password baru
        await user.updatePassword(newPassword);
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }

  // Mengirim email verifikasi
  Future<void> sendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      } else {
        throw Exception('Email already verified');
      }
    } else {
      throw Exception('User not logged in');
    }
  }

  // Mengecek status verifikasi email
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.emailVerified;
    } else {
      throw Exception('User not logged in');
    }
  }

  // Mengaktifkan autentikasi dua faktor
  Future<void> enable2FA() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Anda dapat menambahkan logika untuk mengaktifkan 2FA sesuai dengan API yang tersedia
        // Sebagai contoh, bisa menggunakan Firebase Phone Authentication atau lainnya
        // Misalnya, dengan menggunakan email link atau OTP
      }
    } catch (e) {
      throw Exception('Error enabling 2FA: $e');
    }
  }
}
