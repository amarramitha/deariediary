import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PostController extends GetxController {
  // Reactive list to hold posts
  var posts = <DocumentSnapshot>[].obs;

  // Status loading
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts(); // Fetch posts when the controller is initialized
  }

  // Function to fetch posts from Firestore
  Future<void> fetchPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User is not logged in');
      return;
    }

    try {
      isLoading.value = true;
      // Get posts from Firestore and update the posts list
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get(); // Use get() instead of snapshots() for a one-time fetch

      posts.value = snapshot.docs; // Update the reactive posts list
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Function to add a post
  Future<void> addPost(String content, XFile? image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Pengguna belum login');
      return;
    }

    String? imageUrl;
    if (image != null) {
      try {
        // Upload image to Firebase Storage
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
      // Save post data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .add({
        'content': content,
        'imageUrl': imageUrl, // Save image URL if image is provided
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Post created successfully!');
      fetchPosts(); // Refresh posts after creating a new post
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan postingan: $e');
    }
  }

  // Function to edit a post
  Future<void> editPost(String postId, String newContent) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Pengguna belum login');
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
        // Update the content of the post
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('posts')
            .doc(postId)
            .update({
          'content': newContent,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        Get.snackbar('Success', 'Post updated successfully!');
        fetchPosts(); // Refresh posts after editing
      } else {
        Get.snackbar('Error', 'Postingan tidak ditemukan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengedit postingan: $e');
    }
  }

  // Function to delete a post
  Future<void> deletePost(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Pengguna belum login');
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
        // Delete the post from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('posts')
            .doc(postId)
            .delete();

        Get.snackbar('Success', 'Post deleted successfully!');
        fetchPosts(); // Refresh posts after deletion
      } else {
        Get.snackbar('Error', 'Postingan tidak ditemukan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus postingan: $e');
    }
  }
}
