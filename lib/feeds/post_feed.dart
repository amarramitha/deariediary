import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:deariediary/feeds/add_post.dart';
import 'package:deariediary/widget/postcard.dart';
import 'package:get/get.dart';
import 'package:deariediary/controller/post_controller.dart';
import 'package:deariediary/routes/routes.dart'; // Import the PostController
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

class PostFeedPage extends StatelessWidget {
  final PostController _postController = Get.put(PostController());
  final RxString _userName =
      ''.obs; // Create an observable variable for user name

  // Fetch the user's name from Firestore
  Future<void> _fetchUserName() async {
    try {
      // Get current user ID from FirebaseAuth
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Get user profile data from Firestore
        DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        // Check if profile data exists and extract the name
        if (profileSnapshot.exists) {
          _userName.value = profileSnapshot['name'] ?? 'No Name';
        }
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch user name when the page is built
    _fetchUserName();

    return Scaffold(
      body: Obx(() {
        if (_postController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (_postController.posts.isEmpty) {
          return Center(child: Text('No posts available.'));
        }

        return ListView.builder(
          itemCount: _postController.posts.length,
          itemBuilder: (context, index) {
            var post = _postController.posts[index];
            String content = post['content'] ?? '';
            String imageUrl = post['imageUrl'] ?? '';

            return PostCard(
              postContent: content,
              imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
              userName: _userName.value, // Use the observable user name
              userProfileUrl:
                  null, // Optionally, pass user profile image URL if available
              onEdit: () {
                // Edit functionality if needed
              },
              onDelete: () {
                _postController.deletePost(post.id);
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.addPost);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
