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

  // List of emojis without mood labels
  final List<String> moodEmojis = [
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

  // Define color for each emoji index (you can adjust accordingly)
  final List<Color> emojiColors = [
    Colors.yellow,
    Colors.blue,
    Colors.red,
    Colors.pink,
    Colors.grey,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.blueAccent,
    Colors.amber,
    Colors.black87,
    Colors.green,
    Colors.blue,
    Colors.blueGrey,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.lightGreen,
    Colors.brown,
    Colors.cyan,
    Colors.teal,
  ];

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

            // Ensure valid index for emojis and colors
            int moodIndex = moodEmojis.indexWhere((emoji) => emoji == mood);
            if (moodIndex == -1)
              moodIndex = 0; // Default to first emoji if no match
            String moodEmoji = moodEmojis[moodIndex];
            Color emojiColor = emojiColors[moodIndex];

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
                              fontFamily: 'Jakarta',
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
                                fontFamily: 'Jakarta',
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
                                fontFamily: 'Jakarta',
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
                            color: emojiColor, // Color based on the mood
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
