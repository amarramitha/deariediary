import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:deariediary/feeds/add_post.dart';
import 'package:deariediary/widget/postcard.dart';
import 'package:get/get.dart';
import 'package:deariediary/controller/post_controller.dart';
import 'package:deariediary/routes/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostFeedPage extends StatelessWidget {
  final PostController _postController = Get.put(PostController());
  final RxString _userName = ''.obs;

  Future<void> _fetchUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

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
    // Fetch username once and use FutureBuilder to wait for it
    return FutureBuilder(
      future: _fetchUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Obx(() {
            if (_postController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (_postController.posts.isEmpty) {
              return Center(
                child: Text(
                  'No posts available.',
                  style: TextStyle(fontFamily: 'Jakarta'),
                ),
              );
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
                  userName: _userName.value,
                  userProfileUrl: null,
                  onEdit: () {},
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
      },
    );
  }
}
