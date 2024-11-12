import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // To select photos from the gallery or camera
import 'dart:io';
import 'package:get/get.dart'; // Import GetX for navigation
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage

class EditDiaryPage extends StatefulWidget {
  final String entryId; // ID entri diary yang akan diedit

  EditDiaryPage({required this.entryId});

  @override
  _EditDiaryPageState createState() => _EditDiaryPageState();
}

class _EditDiaryPageState extends State<EditDiaryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  File? _imageFile;
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _loadDiaryEntry();
  }

  // Fungsi untuk mengambil data entri diary yang akan diedit
  Future<void> _loadDiaryEntry() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('diary_entries')
          .doc(widget.entryId)
          .get();

      if (docSnapshot.exists) {
        _titleController.text = docSnapshot['title'];
        _contentController.text = docSnapshot['content'];
        _selectedMood = docSnapshot['mood']; // Loading the current mood
        // If there is a photo URL, you can load it here
        // You may need to handle the image URL retrieval and display accordingly
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load diary entry: $e'),
      ));
    }
  }

  // Fungsi untuk upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('diary_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL(); // Get the image URL
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Fungsi untuk menyimpan perubahan entri diary
  Future<void> _saveEditedDiaryEntry() async {
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Title, content, and mood cannot be empty!'),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload the image to Firebase Storage and get the image URL (if selected)
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      // Directly update the diary entry in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('diary_entries')
          .doc(widget.entryId)
          .update({
        'title': _titleController.text,
        'content': _contentController.text,
        'mood': _selectedMood,
        'imageUrl': imageUrl ?? '', // Save the image URL if available
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Diary entry updated successfully!'),
      ));

      // After successful update, navigate back to the DiaryPage using GetX
      Get.offNamed('home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update diary entry: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk membatalkan perubahan dan kembali
  void _cancelEditing() {
    Get.back(); // Use GetX to go back
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery); // Choose from gallery

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk memilih mood
  void _selectMood(String? mood) {
    setState(() {
      _selectedMood = mood;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Diary Entry"),
        actions: [
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: _cancelEditing, // Tombol Batal
          )
        ],
      ),
      body: SingleChildScrollView(
        // Make the entire body scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title TextField
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              SizedBox(height: 10),

              // Content TextField
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: "Content",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                maxLines: 10,
              ),
              SizedBox(height: 10),

              // Mood Selector (Dropdown)
              DropdownButton<String>(
                value: _selectedMood,
                hint: Text('Select Mood'),
                onChanged: _selectMood,
                items: ['Happy', 'Sad', 'Neutral']
                    .map((mood) => DropdownMenuItem<String>(
                          value: mood,
                          child: Text(mood),
                        ))
                    .toList(),
              ),
              SizedBox(height: 10),

              // Display selected image (if any)
              _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    )
                  : Text("No image selected"),

              // Button to pick an image
              TextButton(
                onPressed: _pickImage,
                child: Text("Choose Photo"),
              ),
              SizedBox(height: 20),

              // Buttons for Save and Cancel
              Row(
                children: [
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _saveEditedDiaryEntry,
                          child: Text("Save Changes"),
                        ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _cancelEditing,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: Text("Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
