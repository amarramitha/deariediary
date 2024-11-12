import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// Fungsi untuk menyimpan postingan baru
Future<void> addPost(String content, XFile? image) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('Pengguna belum login');
  }

  String? imageUrl;
  if (image != null) {
    try {
      // Mengupload gambar ke Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref().child('posts/${image.name}');
      await storageRef.putFile(File(image.path));
      imageUrl = await storageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Gagal meng-upload gambar: $e');
    }
  }

  try {
    // Menyimpan data postingan ke Firestore di bawah pengguna yang sedang login
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('posts')
        .add({
      'content': content,
      'imageUrl': imageUrl, // Jika ada gambar, simpan URL-nya
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    throw Exception('Gagal menyimpan postingan: $e');
  }
}

// Fungsi untuk mengedit postingan
Future<void> editPost(String postId, String newContent) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('Pengguna belum login');
  }

  try {
    // Ambil dokumen postingan untuk memastikan pengguna yang mengedit adalah pemiliknya
    var postDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('posts')
        .doc(postId)
        .get();

    if (postDoc.exists) {
      // Update konten postingan
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .doc(postId)
          .update({
        'content': newContent,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('Postingan tidak ditemukan');
    }
  } catch (e) {
    throw Exception('Gagal mengedit postingan: $e');
  }
}

// Fungsi untuk menghapus postingan
Future<void> deletePost(String postId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('Pengguna belum login');
  }

  try {
    // Ambil dokumen postingan untuk memastikan pengguna yang menghapus adalah pemiliknya
    var postDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('posts')
        .doc(postId)
        .get();

    if (postDoc.exists) {
      // Hapus postingan dari Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .doc(postId)
          .delete();
    } else {
      throw Exception('Postingan tidak ditemukan');
    }
  } catch (e) {
    throw Exception('Gagal menghapus postingan: $e');
  }
}

// Fungsi untuk mengambil postingan milik pengguna
Stream<QuerySnapshot> getUserPosts() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('Pengguna belum login');
  }

  // Mengambil stream dari postingan yang dibuat oleh pengguna
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots();
}

Future<void> _savePost(
    TextEditingController _postController, XFile? _selectedImage) async {
  if (_postController.text.isEmpty && _selectedImage == null) {
    Get.snackbar(
      "Error",
      "Please add content or select an image",
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  try {
    // Call the addPost function
    await addPost(_postController.text, _selectedImage);

    Get.snackbar(
      "Success",
      "Post created successfully!",
      snackPosition: SnackPosition.BOTTOM,
    );

    // Reset form after successful post
    _postController.clear();
    _selectedImage = null;

    // Navigate back to the previous page using GetX
    Get.back(); // This replaces Navigator.pop(context)
  } catch (e) {
    Get.snackbar(
      "Error",
      "Failed to create post. Try again.",
      snackPosition: SnackPosition.BOTTOM,
    );
    print(e);
  }
}

// Fungsi untuk menyimpan postingan dan kembali ke halaman feed menggunakan GetX
