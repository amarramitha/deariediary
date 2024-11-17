import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'add_diary.dart';
import 'package:deariediary/controller/diary_controller.dart';
import 'diary_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class DiaryPage extends StatelessWidget {
  final DiaryController diaryController = Get.put(DiaryController());

  // Map of mood labels to emojis
  final Map<String, String> moodEmojis = {
    'Happy': '😊',
    'Sad': '😢',
    'Angry': '😠',
    'Loved': '😍',
    'Disappointed': '😞',
    'Excited': '😁',
    'Relaxed': '😌',
    'Stressed': '😖',
    'Crying': '😭',
    'Confused': '😕',
    'neutral': '😐', // Default emoji for neutral mood
  };

  // Define color for each mood emoji
  final Map<String, Color> emojiColors = {
    'Happy': Colors.yellow,
    'Sad': Colors.blue,
    'Angry': Colors.red,
    'Loved': Colors.pink,
    'Disappointed': Colors.grey,
    'Excited': Colors.orange,
    'Relaxed': Colors.green,
    'Stressed': Colors.purple,
    'Crying': Colors.blueAccent,
    'Confused': Colors.amber,
    'neutral': Colors.black87,
  };

  @override
  Widget build(BuildContext context) {
    // Fetch diary entries when the page is loaded
    diaryController.fetchDiaryEntries();

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

            final date = entry['date'] as DateTime? ?? DateTime.now();
            final formattedDay = DateFormat('d').format(date);
            final formattedMonth = DateFormat('MMM').format(date);

            String mood = entry['mood'] ?? 'neutral';
            String moodEmoji = moodEmojis[mood] ?? moodEmojis['neutral']!;
            Color emojiColor = emojiColors[mood] ?? emojiColors['neutral']!;

            return GestureDetector(
              onTap: () {
                Get.to(() => DiaryDetailPage(
                      title: entry['title'] ?? 'No Title',
                      content: entry['content'] ?? 'No Content',
                      timestamp: date,
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
                      RichText(
                          text: TextSpan(
                        text: moodEmoji,
                        style: GoogleFonts.notoColorEmoji(
                          textStyle: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      )),
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
