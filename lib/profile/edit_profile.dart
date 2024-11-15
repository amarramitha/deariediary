import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  final String bio;
  final Function(String) onBioUpdated;

  EditProfile({required this.bio, required this.onBioUpdated});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.bio;
  }

  Future<String> _getUserProfilePicture() async {
    User? user = _auth.currentUser;
    if (user?.photoURL != null) {
      return user!.photoURL!;
    }
    return 'https://www.example.com/default-profile.jpg'; // Default image URL
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_imageFile != null) {
      final user = _auth.currentUser;
      final fileName = 'profile_${user!.uid}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child(fileName);
      await storageRef.putFile(_imageFile!);
      final downloadURL = await storageRef.getDownloadURL();
      await user.updatePhotoURL(downloadURL);
    }
  }

  Future<void> _updateLastName() async {
    User? user = _auth.currentUser;
    if (user != null && _lastNameController.text.isNotEmpty) {
      await user.updateDisplayName('${user.displayName} ${_lastNameController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final String? userEmail = user?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,  // Set alignment to start for text
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: FutureBuilder<String>(
                  future: _getUserProfilePicture(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    } else {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : NetworkImage(snapshot.data!) as ImageProvider,
                        child: _imageFile == null
                            ? Icon(Icons.add_a_photo, color: Colors.white, size: 30)
                            : null,
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nama Belakang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                hintText: 'Masukkan Nama Belakang',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Perkenalan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                hintText: 'Masukkan Perkenalan',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            SizedBox(height: 30),
            Text(
              'Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              userEmail ?? 'Email tidak tersedia',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  widget.onBioUpdated(_bioController.text);
                  await _updateLastName();
                  await _uploadProfilePicture();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: Colors.pink.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
