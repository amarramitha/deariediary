import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'add_diary.dart';
import 'package:deariediary/controller/diary_controller.dart';
import 'diary_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryPage extends StatelessWidget {
  final DiaryController diaryController = Get.put(DiaryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (diaryController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // No diary entries available
        if (diaryController.diaryEntries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 50, color: Colors.grey),
                SizedBox(height: 10),
                Text('No diary entries available.'),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => AddDiaryPage());
                  },
                  child: Text('Add Diary Entry'),
                ),
              ],
            ),
          );
        }

        // Display diary entries
        return ListView.builder(
          itemCount: diaryController.diaryEntries.length,
          itemBuilder: (context, index) {
            final entry = diaryController.diaryEntries[index];
            final timestamp = entry['timestamp'];

            final dateTime = (timestamp != null && timestamp is Timestamp)
                ? timestamp.toDate()
                : DateTime.now();

            final formattedDay = DateFormat('d').format(dateTime);
            final formattedMonth = DateFormat('MMM').format(dateTime);

            String mood = entry['mood'] ?? 'neutral';
            Icon moodIcon;
            Color moodColor;

            // Mood icons and colors
            switch (mood) {
              case 'happy':
                moodIcon =
                    Icon(Icons.sentiment_very_satisfied, color: Colors.yellow);
                moodColor = Colors.green;
                break;
              case 'neutral':
                moodIcon = Icon(Icons.sentiment_neutral, color: Colors.orange);
                moodColor = Colors.blue;
                break;
              case 'sad':
                moodIcon =
                    Icon(Icons.sentiment_dissatisfied, color: Colors.blue);
                moodColor = Colors.red;
                break;
              default:
                moodIcon = Icon(Icons.sentiment_neutral, color: Colors.grey);
                moodColor = Colors.grey;
                break;
            }

            // Return the diary entry item as a GestureDetector to navigate to the detail page
            return GestureDetector(
              onTap: () {
                Get.to(() => DiaryDetailPage(
                      title: entry['title'] ?? 'No Title',
                      content: entry['content'] ?? 'No Content',
                      timestamp: dateTime,
                      mood: entry['mood'] ?? 'No Mood',
                      imageUrl: entry['image'] ?? '',
                      entryId: entry['id'] ?? '',
                    ));
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Display the day and month
                      Column(
                        children: [
                          Text(
                            formattedDay,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            formattedMonth,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      // Display the title and content of the entry
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['title'] ?? 'Untitled',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              entry['content'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Display the mood icon
                      moodIcon,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),

      // Floating action button to add a new diary entry
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddDiaryPage());
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 240, 183, 202),
        tooltip: 'Add Diary Entry',
      ),
    );
  }
}
