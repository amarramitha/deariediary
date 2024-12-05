import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfile extends StatefulWidget {
  final String bio;
  final Function(String) onBioUpdated;
  final Function(String)
      onProfileImageUpdated; // New callback for profile image update

  EditProfile(
      {required this.bio,
      required this.onBioUpdated,
      required this.onProfileImageUpdated});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _bioController;
  late TextEditingController _nameController;
  String _profileImageUrl = '';
  bool _isLoading = true;

  final List<String> _avatars = [
    'images/avatar1.jpg',
    'images/avatar2.jpg', // Add more avatars
    'images/avatar3.jpg', // Add more avatars
    'images/avatar4.jpg', // Add more avatars
    'images/avatar5.jpg', // Add more avatars
    'images/avatar6.jpg', // Add more avatars
    'images/avatar7.jpg', // Add more avatars
    'images/avatar8.jpg', // Add more avatars
    'images/avatar9.jpg', // Add more avatars
    'images/avatar10.jpg', // Add more avatars
    'images/avatar11.jpg', // Add more avatars
    'images/avatar12.jpg', // Add more avatars
    'images/avatar13.jpg', // Add more avatars
    'images/avatar14.jpg', // Add more avatars
    'images/avatar15.jpg', // Add more avatars
    'images/avatar16.jpg', // Add more avatars
    'images/avatar17.jpg', // Add more avatars
  ];

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.bio);
    _nameController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null) {
            setState(() {
              _nameController.text = data['name'] ?? '';
              _bioController.text = data['bio'] ?? '';
              _profileImageUrl = data['photoURL'] ?? '';
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(_nameController.text);
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'bio': _bioController.text,
          'photoURL': _profileImageUrl,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  // Avatar selection
  Future<void> _selectAvatar(String avatarUrl) async {
    setState(() {
      _profileImageUrl = avatarUrl;
    });
    widget.onProfileImageUpdated(_profileImageUrl); // Update profile image
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Pilih Avatar'),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: _avatars.map((avatarUrl) {
                                    return GestureDetector(
                                      onTap: () {
                                        _selectAvatar(avatarUrl);
                                        Navigator.pop(context);
                                      },
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage:
                                            NetworkImage(avatarUrl),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImageUrl.isNotEmpty
                            ? NetworkImage(_profileImageUrl)
                            : null,
                        child: _profileImageUrl.isEmpty
                            ? Icon(Icons.add_a_photo,
                                color: Colors.white, size: 30)
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField('Nama', _nameController, 'Masukkan Nama'),
                  SizedBox(height: 20),
                  _buildTextField('Bio', _bioController, 'Masukkan Perkenalan'),
                  SizedBox(height: 30),
                  Text('Email',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(_auth.currentUser?.email ?? 'Email tidak tersedia'),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _updateUserData();
                        widget.onBioUpdated(_bioController.text); // Update bio
                        Navigator.pop(context);
                      },
                      child: Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
