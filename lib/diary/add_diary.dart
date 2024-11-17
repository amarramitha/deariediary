  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:get/get.dart';
  import 'package:deariediary/controller/diary_controller.dart';
  import 'dashboard_diary.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:flutter_sound/flutter_sound.dart';
  import 'dart:io';
  import 'package:image_picker_web/image_picker_web.dart';
  import 'package:flutter/foundation.dart';

  class AddDiaryPage extends StatefulWidget {
    final String? entryId;
    final String? existingTitle;
    final String? existingContent;

    AddDiaryPage({
      this.entryId,
      this.existingTitle,
      this.existingContent,
    });

    @override
    _AddDiaryPageState createState() => _AddDiaryPageState();
  }

  class _AddDiaryPageState extends State<AddDiaryPage> {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();
    final DiaryController diaryController = Get.put(DiaryController());
    bool _isLoading = false;
    String? _mood;
    File? _imageFile;
    String? _audioFilePath;
    FlutterSoundRecorder? _recorder;
    DateTime selectedDate = DateTime.now();
    final _formKey = GlobalKey<FormState>();

    final List<Map<String, String>> moods = [
      {'emoji': '😊', 'label': 'Happy'},
      {'emoji': '😢', 'label': 'Sad'},
      {'emoji': '😠', 'label': 'Angry'},
      {'emoji': '😍', 'label': 'Loved'},
      {'emoji': '😞', 'label': 'Disappointed'},
      {'emoji': '😁', 'label': 'Excited'},
      {'emoji': '😌', 'label': 'Relaxed'},
      {'emoji': '😖', 'label': 'Stressed'},
      {'emoji': '😭', 'label': 'Crying'},
      {'emoji': '😕', 'label': 'Confused'},
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

    Future<void> _pickImage() async {
      if (kIsWeb) {
        // Image picking for Web (using ImagePickerWeb)
        final pickedFile = await ImagePickerWeb.getImageAsFile();
        if (pickedFile != null) {
          setState(() {
            _imageFile = pickedFile as File?;
          });

          // Upload the image to Firebase Storage
          if (_imageFile != null) {
            await diaryController.uploadImageToFirebase(_imageFile!);
          }
        }
      } else {
        // Image picking for mobile (using ImagePicker)
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
          });

          // Upload the image to Firebase Storage
          if (_imageFile != null) {
            await diaryController.uploadImageToFirebase(_imageFile!);
          }
        }
      }
    }

    Future<void> _startRecording() async {
      try {
        await _recorder!.startRecorder(toFile: 'audio.m4a');
        setState(() {
          _audioFilePath = null; // Reset audio file path
        });
      } catch (e) {
        print("Error starting recorder: $e");
      }
    }

    Future<void> _stopRecording() async {
      try {
        final path = await _recorder!.stopRecorder();
        setState(() {
          _audioFilePath = path;
        });
      } catch (e) {
        print("Error stopping recorder: $e");
      }
    }

    Future<void> _selectMood(BuildContext context) async {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Bagaimana moodmu hari ini?'),
          content: Wrap(
            spacing: 16,
            children: moods.map((mood) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _mood = mood['label'];
                  });
                  Navigator.pop(context);
                },
                child: Column(
                  children: [
                    Text(mood['emoji']!, style: const TextStyle(fontSize: 30, fontFamily: 'NotoColorEmoji')),
                    Text(mood['label']!, style: TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
      );

      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked; // Update the selected date
        });
      }
    }

    Future<void> saveDiaryEntry() async {
      if (!_formKey.currentState!.validate()) return; // Validate form fields
      setState(() => _isLoading = true); // Show loading indicator

      try {
        // Use selectedDate directly as it is already a DateTime
        DateTime selectedDateToSave = selectedDate; // This is already DateTime

        if (widget.entryId == null) {
          // Adding new entry
          await diaryController.addDiaryEntry(
            context,
            title: _titleController.text,
            content: _contentController.text,
            mood: _mood ?? '',
            image: _imageFile,
            audioFilePath: _audioFilePath,
            date: selectedDateToSave, // Pass as DateTime
          );
        } else {
          // Updating existing entry
          await diaryController.updateDiaryEntry(
            entryId: widget.entryId!,
            title: _titleController.text,
            content: _contentController.text,
            mood: _mood ?? '',
            image: _imageFile,
            audioFilePath: _audioFilePath,
            date: selectedDateToSave, // Pass as DateTime
            context: context,
          );
        }

        Get.offAll(() => DashboardDiary()); // Navigate to Dashboard after saving
      } catch (e) {
        // Display error message if saving fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save diary entry: $e')),
        );
      } finally {
        setState(() => _isLoading = false); // Hide loading indicator
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
              onPressed: saveDiaryEntry,
            ),
          ],
        ),
        backgroundColor: Colors.pink[50],
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey, // Add form key here
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
                            DateFormat('yMMMd').format(selectedDate),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (_mood != null) Text('Mood: $_mood'),
                          IconButton(
                            onPressed: () => _selectMood(context),
                            icon: Icon(Icons.emoji_emotions),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Card(
                    color: Colors.pink[50],
                    margin: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          // Title TextFormField
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30),

                          // Content TextFormField
                          Expanded(
                            child: TextFormField(
                              controller: _contentController,
                              decoration: InputDecoration(
                                labelText: 'Content',
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some content';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
