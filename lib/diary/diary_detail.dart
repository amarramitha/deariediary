import 'package:deariediary/controller/diary_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import untuk DateFormat
import 'package:get/get.dart'; // Import GetX
import 'package:deariediary/diary/edit_diary.dart'; // Import EditDiaryPage

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
    // Initialize the controller here
    final controller = Get.find<DiaryController>();

    // Now you can use the controller
    return Scaffold(
      appBar: AppBar(
        title: Text("Diary Entry Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
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
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (String result) {
                        if (result == 'edit') {
                          Get.to(() => EditDiaryPage(entryId: entryId));
                        } else if (result == 'delete') {
                          // Logic to delete, show confirmation
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete Diary Entry'),
                                content: Text(
                                    'Are you sure you want to delete this entry?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Use the controller to delete the entry
                                      controller.deleteDiaryEntry(
                                          context, entryId);
                                      Navigator.pop(context); // Close dialog
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
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
                SizedBox(height: 8),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm')
                      .format(timestamp), // Format timestamp
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Divider(height: 30, thickness: 1),
                Text(
                  content,
                  style: TextStyle(fontSize: 18, height: 1.5),
                ),
                SizedBox(height: 16),
                Text(
                  "Mood: $mood",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (imageUrl.isNotEmpty)
                  Image.network(imageUrl), // Show image if URL is available
              ],
            ),
          ),
        ),
      ),
    );
  }
}
