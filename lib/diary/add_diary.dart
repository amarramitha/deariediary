import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String? _mood; // Store only emoji here
  File? _imageFile;
  String? _audioFilePath;
  FlutterSoundRecorder? _recorder;
  DateTime selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();

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

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final pickedFile = await ImagePickerWeb.getImageAsFile();
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile as File?;
        });
        if (_imageFile != null) {
          await diaryController.uploadImageToFirebase(_imageFile!);
        }
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
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
        _audioFilePath = null;
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
                  _mood = mood;
                });
                Navigator.pop(context);
              },
              child: Column(
                children: [
                  Text(
                    mood,
                    style: GoogleFonts.notoColorEmoji(
                      textStyle: const TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
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
        selectedDate = picked;
      });
    }
  }

  Future<void> saveDiaryEntry() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      DateTime selectedDateToSave = selectedDate;

      if (widget.entryId == null) {
        await diaryController.addDiaryEntry(
          context,
          title: _titleController.text,
          content: _contentController.text,
          mood: _mood ?? '', // Save only emoji to database
          image: _imageFile,
          audioFilePath: _audioFilePath,
          date: selectedDateToSave,
        );
      } else {
        await diaryController.updateDiaryEntry(
          entryId: widget.entryId!,
          title: _titleController.text,
          content: _contentController.text,
          mood: _mood ?? '', // Save only emoji to database
          image: _imageFile,
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
                          DateFormat('yMMMd').format(_selectedDate),
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
                        SizedBox(height: 10),
                        if (_imageFile != null)
                          Image.file(
                            _imageFile!,
                            height: 150,
                          ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.image, size: 30),
                              onPressed: _pickImage,
                            ),
                          ],
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
