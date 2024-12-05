import 'package:deariediary/feeds/post_feed.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:deariediary/controller/post_controller.dart';
import 'package:deariediary/routes/routes.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _postController = TextEditingController();
  XFile? _selectedImage;
  bool _isLoading = false;

  final PostController _postControllerInstance = Get.put(PostController());

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
      backgroundColor: Colors.pink[50], // Light pink background color
      appBar: AppBar(
        backgroundColor:
            Colors.pink[50], // Set the AppBar background color to pink
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.pink[50],
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    "Post",
                    style: TextStyle(fontSize: 18, fontFamily: 'Jakarta'),
                  ),
            onPressed: _isLoading ? null : _savePost,
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Make the TextField full-width using Expanded and remove the border
            Expanded(
              child: TextField(
                controller: _postController,
                decoration: InputDecoration(
                  hintText: "Yuk tuangkan sambatanmu disini!",
                  alignLabelWithHint: true, // Keeps hint aligned to the top

                  contentPadding: EdgeInsets.only(
                    top: 16,
                    left: 8,
                  ), // Adjust padding to align text to the top
                  border: InputBorder.none, // Remove the underline/border
                ),
                maxLines: null,
              ),
            ),
            SizedBox(height: 10),
            if (_selectedImage != null)
              Image.file(
                File(_selectedImage!.path),
                height: 150,
              ),
          ],
        ),
      ),
    );
  }
}
