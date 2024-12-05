import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deariediary/controller/diary_controller.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:google_fonts/google_fonts.dart';

class EditDiaryPage extends StatefulWidget {
  final String entryId;

  EditDiaryPage({required this.entryId});

  @override
  _EditDiaryPageState createState() => _EditDiaryPageState();
}

class _EditDiaryPageState extends State<EditDiaryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedMood;
  DateTime? _selectedDate;

  final List<String> moodList = [
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
    '😮‍💨'
  ];

  @override
  void initState() {
    super.initState();
    final controller = Get.find<DiaryController>();
    final entry = controller.diaryEntries
        .firstWhere((entry) => entry['id'] == widget.entryId);
    _titleController.text = entry['title'];
    _contentController.text = entry['content'];
    _selectedMood = entry['mood'];
    _selectedDate = entry['date'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // Save the changes
              final controller = Get.find<DiaryController>();
              controller.updateDiaryEntry(
                context,
                entryId: widget.entryId, // Make sure to send entryId
                title: _titleController.text,
                content: _contentController.text,
                mood: _selectedMood ??
                    '😊', // Default to smile if no mood selected
                date: _selectedDate,
              );
              Get.offAllNamed('/home'); // Go back to the home page
              controller
                  .fetchDiaryEntries(); // Refresh the diary entries after saving
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.pink[50],
        padding: const EdgeInsets.all(0),
        child: Card(
          color: Colors.pink[50],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date display with formatting
                    GestureDetector(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != _selectedDate) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            DateFormat('yyyy-MM-dd')
                                .format(_selectedDate ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mood emoji selector with a pop-up
                    GestureDetector(
                      onTap: () {
                        _showMoodSelector(context);
                      },
                      child: Text(
                        _selectedMood ??
                            '😊', // Default to a smile if no mood is selected
                        style: GoogleFonts.notoColorEmoji(fontSize: 24),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Title input field without a border
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Bagaimana harimu?',
                    border: InputBorder.none, // No border
                  ),
                ),
                SizedBox(height: 16),
                // Content input field without a border
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Yuk bagikan ceritamu disini!',
                    border: InputBorder.none, // No border
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to show mood selector in a grid pop-up
  void _showMoodSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Bagaimana mood kamu?',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Jakarta',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: moodList.length,
              itemBuilder: (BuildContext gridContext, int index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = moodList[index]; // Update selected mood
                    });
                    Navigator.of(gridContext)
                        .pop(); // Close dialog after selection
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        moodList[index],
                        style: GoogleFonts.notoColorEmoji(fontSize: 30),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
