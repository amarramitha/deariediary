import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  TextEditingController _bioController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.bio;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Fetch data from Firestore
      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          setState(() {
            _nameController.text =
                data['name'] ?? ''; // Ensure name is retrieved here
            _bioController.text = data['bio'] ?? ''; // Ensure bio is retrieved
          });
        }
      }
    }
  }

  Future<String> _getUserProfilePicture() async {
    User? user = _auth.currentUser;
    if (user?.photoURL != null) {
      return user!.photoURL!;
    }
    return 'https://www.example.com/default-profile.jpg'; // Default image URL
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
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
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(fileName);
      await storageRef.putFile(_imageFile!);
      final downloadURL = await storageRef.getDownloadURL();
      await user.updatePhotoURL(downloadURL);
      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': downloadURL,
      });
    }
  }

  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final fullName = _nameController.text; // Use the single name field
      await user.updateDisplayName(fullName);

      // Update Firestore data
      await _firestore.collection('users').doc(user.uid).set({
        'name': _nameController.text, // Ensure this is properly set
        'bio': _bioController.text,
      }, SetOptions(merge: true)); // Merges with existing data
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                            ? Icon(Icons.add_a_photo,
                                color: Colors.white, size: 30)
                            : null,
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nama',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jakarta'),
            ),
            SizedBox(height: 4),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Masukkan Nama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Bio',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jakarta'),
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
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jakarta'),
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
                  await _updateUserData();
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
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Jakarta'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
