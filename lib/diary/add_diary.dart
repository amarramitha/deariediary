import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:deariediary/controller/diary_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'dashboard_diary.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class AddDiaryPage extends StatefulWidget {
  final String? entryId;
  final String? existingTitle;
  final String? existingContent;

  AddDiaryPage({this.entryId, this.existingTitle, this.existingContent});

  @override
  _AddDiaryPageState createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final DiaryController diaryController = Get.put(DiaryController());
  bool _isLoading = false;
  String? _mood;
  List<File>? _imageFiles = [];
  List<Uint8List>? _imageBytesList = [];
  String? _audioFilePath;
  FlutterSoundRecorder? _recorder;
  DateTime selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  final List<String> moods = [
    '😊',
    '😢',
    '😠',
    '😍',
    '😞',
    '😁',
    '😌',
    '😖',
    '😭',
    '😕',
    '😎',
    '🤣',
    '🥳',
    '😴',
    '🤒',
    '🤔',
    '🥱',
    '🥴',
    '🤑',
    '😮‍💨',
  ];

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    if (widget.entryId != null) {
      _titleController.text = widget.existingTitle ?? '';
      _contentController.text = widget.existingContent ?? '';
    }
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      await _recorder!.openRecorder();
    } catch (e) {
      print("Error opening audio session: $e");
    }
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName =
          'diary_images/${DateTime.now().millisecondsSinceEpoch}.png';
      final fileRef = storageRef.child(fileName);

      await fileRef.putFile(imageFile);

      final imageUrl = await fileRef.getDownloadURL();
      print('Image uploaded: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickImages() async {
    if (kIsWeb) {
      // Picking multiple images on the web
      final List<Uint8List>? pickedImages = await ImagePickerWeb.pickImages();

      if (pickedImages != null && pickedImages.isNotEmpty) {
        setState(() {
          _imageBytesList =
              pickedImages; // _imageBytesList should be a List<Uint8List>
          _imageFiles = []; // Reset the mobile-specific list if necessary
        });
      }
    } else {
      // Use ImagePicker for mobile (android/ios) devices
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          _imageFiles =
              pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
          _imageBytesList = []; // Reset the web-specific list if necessary
        });
      }
    }
  }

  Future<void> saveDiaryEntry(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      DateTime selectedDateToSave = selectedDate;

      // Upload all images and get their URLs
      List<String> imageUrls = [];
      if (_imageFiles != null && _imageFiles!.isNotEmpty) {
        for (var imageFile in _imageFiles!) {
          String? imageUrl = await uploadImageToFirebase(imageFile);
          if (imageUrl != null) {
            imageUrls.add(imageUrl);
          }
        }
      } else if (_imageBytesList != null && _imageBytesList!.isNotEmpty) {
        for (var imageBytes in _imageBytesList!) {
          final file = await _createFileFromBytes(imageBytes);
          String? imageUrl = await uploadImageToFirebase(file);
          if (imageUrl != null) {
            imageUrls.add(imageUrl);
          }
        }
      }

      // Save diary entry with multiple image URLs
      if (widget.entryId == null) {
        await diaryController.addDiaryEntry(
          context,
          title: _titleController.text,
          content: _contentController.text,
          mood: _mood ?? '',
          imageUrls: imageUrls, // Pass the list of image URLs
          audioFilePath: _audioFilePath,
          date: selectedDateToSave,
        );
      } else {
        await diaryController.updateDiaryEntry(
          entryId: widget.entryId!,
          title: _titleController.text,
          content: _contentController.text,
          mood: _mood ?? '',
          imageUrls: imageUrls, // Pass the list of image URLs
          audioFilePath: _audioFilePath,
          date: selectedDateToSave,
          context: context,
        );
      }

      Get.offAll(() => DashboardDiary());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save diary entry: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<File> _createFileFromBytes(Uint8List bytes) async {
    if (kIsWeb) {
      final file = File('${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      return file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.pink[50],
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => saveDiaryEntry(context),
          ),
        ],
      ),
      backgroundColor: Colors.pink[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _selectDate(context),
                          icon: Icon(Icons.calendar_today),
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _selectMood(context),
                      icon: Icon(Icons.sentiment_satisfied_alt),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter content' : null,
                  maxLines: 6,
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImages,
                  child: _imageFiles!.isEmpty && _imageBytesList!.isEmpty
                      ? Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Center(
                            child: Icon(Icons.add_a_photo),
                          ),
                        )
                      : Column(
                          children: _imageFiles!
                              .map(
                                (file) => Image.file(
                                  file,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                              .toList(),
                        ),
                ),
                SizedBox(height: 8),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => saveDiaryEntry(context),
                        child: Text(widget.entryId == null
                            ? 'Add Entry'
                            : 'Update Entry'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to select date
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Function to select mood
  Future<void> _selectMood(BuildContext context) async {
    final selectedMood = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Mood'),
        content: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemCount: moods.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop(moods[index]);
              },
              child: Center(
                  child: Text(moods[index], style: TextStyle(fontSize: 30))),
            );
          },
        ),
      ),
    );

    if (selectedMood != null) {
      setState(() {
        _mood = selectedMood;
      });
    }
  }
}
