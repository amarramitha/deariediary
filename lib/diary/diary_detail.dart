import 'package:deariediary/controller/diary_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:get/get.dart'; // Import GetX
import 'package:deariediary/diary/edit_diary.dart'; // Import EditDiaryPage
import 'package:google_fonts/google_fonts.dart';

class DiaryDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final DateTime timestamp;
  final String mood;
  final String imageUrl;
  final String entryId;

  const DiaryDetailPage({
    Key? key,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.mood,
    required this.imageUrl,
    required this.entryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiaryController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'edit') {
                Get.to(() => EditDiaryPage(entryId: entryId));
              } else if (result == 'delete') {
                _showDeleteDialog(context, controller);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.pink[50],
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Colors.pink[50],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date display with formatting
                    Text(
                      DateFormat('yyyy-MM-dd').format(timestamp),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    // Mood emoji directly fetched from the database
                    RichText(
                      text: TextSpan(
                        text:
                            mood, // Directly use the mood data from the database
                        style: GoogleFonts.notoColorEmoji(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Title of the diary entry
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Jakarta',
                  ),
                ),
                SizedBox(height: 8),
                Divider(height: 30, thickness: 1),
                // Content of the diary entry
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    fontFamily: 'Jakarta',
                  ),
                ),
                SizedBox(height: 16),
                // Display the image if there is one
                if (imageUrl.isNotEmpty) Image.network(imageUrl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to show the delete confirmation dialog
  void _showDeleteDialog(BuildContext context, DiaryController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Diary Entry'),
          content: Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await controller.deleteDiaryEntry(entryId);
                Navigator.pop(context); // Close the dialog
                Get.back(); // Go back to the previous page after deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
