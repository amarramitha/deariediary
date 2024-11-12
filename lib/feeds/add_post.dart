import 'package:deariediary/feeds/post_feed.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:deariediary/controller/post_controller.dart';
import 'package:deariediary/controller/dashboard_controller.dart';
import 'package:deariediary/routes/routes.dart'; // Import the controller

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _postController = TextEditingController();
  XFile? _selectedImage;
  bool _isLoading = false;

  // Create an instance of the PostController
  final PostController _postControllerInstance = Get.put(PostController());

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _savePost() async {
    if (_postController.text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add content or select an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _postControllerInstance.addPost(
          _postController.text, _selectedImage);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post created successfully!')),
      );

      // Reset form setelah berhasil menambah post
      _postController.clear();
      setState(() {
        _selectedImage = null;
      });

      Get.offNamed('postFeed');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post. Try again.')),
      );
      print("Error creating post: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Post")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input for content
            TextField(
              controller: _postController,
              decoration: InputDecoration(labelText: "What's on your mind?"),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            // Display selected image
            if (_selectedImage != null)
              Image.file(
                File(_selectedImage!.path),
                height: 150,
              ),
            SizedBox(height: 10),
            Row(
              children: [
                // Button to pick an image
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Upload Image"),
                ),
                Spacer(),
                // Button to save the post
                ElevatedButton(
                  onPressed: _isLoading ? null : _savePost,
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Post"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
