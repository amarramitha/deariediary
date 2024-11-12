import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:deariediary/controller/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController();
  String _name = "";
  String _photoUrl = "";
  File? _image;
  bool _isLoading = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadProfile();
  }

  // Load profile data
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var profile = await _controller.getProfile();
      setState(() {
        _name = profile['name'] ?? '';
        _photoUrl = profile['photoUrl'] ?? '';
        _nameController.text = _name;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load profile')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Pick profile image from gallery
  Future<void> _pickImage() async {
    File? selectedImage = await _controller.pickImage();
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
      });
    }
  }

  // Update profile with name and photo
  Future<void> _updateProfile() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      String photoUrl = _photoUrl;

      if (_image != null) {
        // Upload new image
        photoUrl = await _controller.uploadImage(_image!);
      }

      // Update profile in Firestore and FirebaseAuth
      await _controller.updateProfile(_name, photoUrl);

      setState(() {
        _photoUrl = photoUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update profile')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Logout function
  Future<void> _logout() async {
    try {
      await _controller.logout();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to log out')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : _photoUrl.isNotEmpty
                              ? NetworkImage(_photoUrl)
                              : AssetImage('assets/default_profile.png')
                                  as ImageProvider,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Name input field
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Name"),
                    onChanged: (value) {
                      setState(() {
                        _name = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text('Update Profile'),
                  ),
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text('Logout'),
                  ),
                ],
              ),
      ),
    );
  }
}
