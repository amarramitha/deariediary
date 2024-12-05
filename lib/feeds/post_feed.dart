import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:deariediary/widget/postcard.dart';
import 'package:get/get.dart';
import 'package:deariediary/controller/post_controller.dart';
import 'package:deariediary/routes/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostFeedPage extends StatelessWidget {
  final PostController _postController = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x64F6DADA),
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

        return StreamBuilder<DocumentSnapshot>(
          stream: _getUserProfileStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading profile data'));
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              var userData = snapshot.data!;
              String userName = userData['name'] ?? 'No Name';
              String userProfileUrl = userData['photoURL'] ?? '';

              return ListView.builder(
                itemCount: _postController.posts.length,
                itemBuilder: (context, index) {
                  var post = _postController.posts[index];
                  String content = post['content'] ?? '';

                  return PostCard(
                    postContent: content,
                    userName: userName,
                    userProfileUrl: userProfileUrl,
                    onDelete: () {
                      _postController.deletePost(post.id);
                    },
                  );
                },
              );
            } else {
              return Center(child: Text('No user profile found.'));
            }
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.addPost);
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 240, 183, 202),
      ),
    );
  }

  // Stream to listen for changes in the user's profile data
  Stream<DocumentSnapshot> _getUserProfileStream() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots();
    } else {
      return Stream.empty();
    }
  }
}
