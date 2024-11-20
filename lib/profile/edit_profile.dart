import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html; // Hanya untuk platform web
import 'package:flutter/foundation.dart'; // Untuk kIsWeb

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
  html.File? _webImageFile; // For web
  String? _mobileImagePath; // For mobile
  late TextEditingController _bioController;
  late TextEditingController _nameController;
  String _profileImageUrl = '';

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
              _profileImageUrl =
                  data['photoURL'] ?? ''; // Load the profile picture URL
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_mobileImagePath == null && _webImageFile == null) return;

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User tidak ditemukan.');

      final fileName = 'profile_${user.uid}.jpg';
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_pictures/$fileName');
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      UploadTask uploadTask;
      if (_mobileImagePath != null) {
        final file = File(_mobileImagePath!);
        uploadTask = storageRef.putFile(file, metadata);
      } else {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webImageFile!);
        await reader.onLoad.first;
        final bytes = reader.result as Uint8List;
        uploadTask = storageRef.putData(bytes, metadata);
      }

      final snapshot = await uploadTask;
      final downloadURL = await snapshot.ref.getDownloadURL();

      await user.updatePhotoURL(downloadURL);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'photoURL': downloadURL});

      setState(() {
        _profileImageUrl = downloadURL; // Update the local image URL
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto profil berhasil diperbarui!')));
    } catch (e) {
      print('Error saat mengunggah foto: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal unggah foto: $e')));
    }
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        final pickedFile = await _pickImageWeb();
        if (pickedFile != null) {
          setState(() {
            _webImageFile = pickedFile;
            _mobileImagePath = null;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Foto berhasil dipilih!')));
        }
      } else {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _mobileImagePath = pickedFile.path;
            _webImageFile = null;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Foto berhasil dipilih!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tidak ada foto yang dipilih!')));
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<html.File?> _pickImageWeb() async {
    final completer = Completer<html.File?>();
    try {
      final html.FileUploadInputElement input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.click();
      input.onChange.listen((e) async {
        final files = input.files;
        if (files!.isEmpty) {
          completer.complete(null);
        } else {
          final file = files[0];
          completer.complete(file);
        }
      });
    } catch (e) {
      print('Error picking image in web: $e');
      completer.completeError(e);
    }
    return completer.future;
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

  @override
  Widget build(BuildContext context) {
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
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImageUrl.isNotEmpty
                      ? NetworkImage(_profileImageUrl)
                      : AssetImage('assets/default_profile_image.jpg')
                          as ImageProvider,
                  child: (_mobileImagePath == null && _webImageFile == null)
                      ? Icon(Icons.add_a_photo, color: Colors.white, size: 30)
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField('Nama', _nameController, 'Masukkan Nama'),
            SizedBox(height: 20),
            _buildTextField('Bio', _bioController, 'Masukkan Perkenalan',
                maxLines: null),
            SizedBox(height: 30),
            Text('Email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(_auth.currentUser?.email ?? 'Email tidak tersedia',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  widget.onBioUpdated(_bioController.text);
                  await _updateUserData();
                  await _uploadProfilePicture();
                  Navigator.pop(context);
                },
                child: Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {int? maxLines}) {
    return TextField(
      controller: controller,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
      ),
    );
  }
}
