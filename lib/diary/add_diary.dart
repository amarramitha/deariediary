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
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();

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
      final pickedFile = await ImagePickerWeb.getImageAsFile();
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile as File?;
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
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
    // Show dialog instead of bottom sheet
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bagaimana moodmu hari ini?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Wrap(
          spacing: 16,
          children: moods.map((mood) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _mood = mood['label'];
                });
                Navigator.pop(context); // Close the dialog
              },
              child: Column(
                children: [
                  Text(mood['emoji']!, style: TextStyle(fontSize: 30)),
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
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> saveDiaryEntry() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (widget.entryId == null) {
        await diaryController.addDiaryEntry(
          context,
          title: _titleController.text,
          content: _contentController.text,
          mood: _mood ?? '',
          image: _imageFile,
          audioFilePath: _audioFilePath,
        );
      } else {
        await diaryController.updateDiaryEntry(
          entryId: widget.entryId!,
          title: _titleController.text,
          content: _contentController.text,
          mood: _mood ?? '',
          image: _imageFile,
          audioFilePath: _audioFilePath,
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Spreads the elements to the edges
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _selectDate(context),
                        icon: Icon(Icons.calendar_today),
                      ),
                      Text(
                        ' ${DateFormat('yMMMd').format(_selectedDate)}',
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
                color: Colors.pink[50], // Card color
                margin: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  height:
                      MediaQuery.of(context).size.height, // Full screen height
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors
                        .transparent, // Transparent background for the container
                    borderRadius:
                        BorderRadius.circular(10), // Rounded corners (optional)
                  ),
                  child: Column(
                    children: [
                      // Title TextFormField
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: InputBorder
                              .none, // Remove the border under the text field
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
                          maxLines: null, // Allows for unlimited lines
                          keyboardType: TextInputType.multiline,
                        ),
                      ),

                      // Buttons Row (Image and Microphone buttons)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.image),
                              label: Text(''),
                            ),
                            ElevatedButton.icon(
                              onPressed: _startRecording,
                              icon: Icon(Icons.mic),
                              label: Text(''),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
