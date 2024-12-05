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
      backgroundColor: const Color(0x64F6DADA),
      body: Obx(() {
        if (diaryController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (diaryController.diaryEntries.isEmpty) {
          return const Center(
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

        return SingleChildScrollView(
          child: Column(
            children: [
              // Fixed Image at the top
              Container(
                width: double.infinity,
                height: 250, // Adjust height as needed
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'images/homepage.png'), // Change to your image asset
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                  height: 20), // Space between image and diary entries

              // Scrollable Diary Entries
              ListView.builder(
                shrinkWrap:
                    true, // Ensures list is scrollable within the SingleChildScrollView
                itemCount: diaryController.diaryEntries.length,
                itemBuilder: (context, index) {
                  final entry = diaryController.diaryEntries[index];
                  final date = entry['date'] as DateTime? ?? DateTime.now();
                  final formattedDay = DateFormat('d').format(date);
                  final formattedMonth = DateFormat('MMM').format(date);

                  String mood = entry['mood'] ?? 'neutral';

                  int moodIndex =
                      moodEmojis.indexWhere((emoji) => emoji == mood);
                  if (moodIndex == -1) moodIndex = 0;
                  String moodEmoji = moodEmojis[moodIndex];
                  Color emojiColor = emojiColors[moodIndex];

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => DiaryDetailPage(
                            title: entry['title'] ?? 'No Title',
                            content: entry['content'] ?? 'No Content',
                            timestamp: date,
                            mood: entry['mood'] ?? 'No Mood',
                            entryId: entry['id'] ?? '',
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontFamily: 'Jakarta',
                                  ),
                                ),
                                Text(
                                  formattedMonth,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry['title'] ?? 'Untitled',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Jakarta',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    entry['content'] ?? '',
                                    style: const TextStyle(
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
                                  color: emojiColor,
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddDiaryPage());
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 240, 183, 202),
      ),
    );
  }
}
