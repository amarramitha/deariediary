import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PostController extends GetxController {
  var posts = <DocumentSnapshot>[].obs;
  var isLoading = false.obs;
  var _userProfileUrl = ''.obs; // Reactive variable for user profile URL

  @override
  void onInit() {
    super.onInit();
    fetchPosts(); // Fetch posts when the controller is initialized
  }

  Future<void> fetchPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User is not logged in');
      return;
    }

    try {
      isLoading.value = true;
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      posts.value = snapshot.docs; // Update the reactive posts list
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPost(String content, XFile? image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Pengguna belum login');
      return;
    }

    String? imageUrl;
    if (image != null) {
      try {
        final storageRef =
            FirebaseStorage.instance.ref().child('posts/${image.name}');
        await storageRef.putFile(File(image.path));
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        Get.snackbar('Error', 'Gagal meng-upload gambar: $e');
        return;
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .add({
        'content': content,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Berhasil', 'Postingan berhasil ditambahkan!');
      fetchPosts(); // Refresh posts after creating a new post
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menyimpan postingan: $e');
    }
  }

  // Future<void> editPost(String postId, String newContent) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     Get.snackbar('Error', 'Pengguna belum login');
  //     return;
  //   }

  //   try {
  //     var postDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .collection('posts')
  //         .doc(postId)
  //         .get();

  //     if (postDoc.exists) {
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(user.uid)
  //           .collection('posts')
  //           .doc(postId)
  //           .update({
  //         'content': newContent,
  //         'updatedAt': FieldValue.serverTimestamp(),
  //       });

  //       Get.snackbar('Berhasil', 'Post updated successfully!');
  //       fetchPosts(); // Refresh posts after editing
  //     } else {
  //       Get.snackbar('Error', 'Postingan tidak ditemukan');
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Gagal mengedit postingan: $e');
  //   }
  // }

  Future<void> deletePost(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Gagal', 'Pengguna belum login');
      return;
    }

    try {
      var postDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .doc(postId)
          .get();

      if (postDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('posts')
            .doc(postId)
            .delete();

        Get.snackbar('Berhasil', 'Postingan berhasil dihapus!');
        fetchPosts(); // Refresh posts after deletion
      } else {
        Get.snackbar('Gagal', 'Postingan tidak ditemukan');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus postingan: $e');
    }
  }

  // Update the profile URL in the controller
  void updateUserData(String newProfileUrl) {
    _userProfileUrl.value = newProfileUrl;
    fetchPosts(); // Refresh posts to reflect the new profile URL
  }

  // Getter for profile URL
  String get userProfileUrl => _userProfileUrl.value;
}
