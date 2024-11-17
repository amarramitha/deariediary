import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodTrackerPage extends StatefulWidget {
  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, String> _moodEmojis = {};  // To store mood emojis for each day

  @override
  void initState() {
    super.initState();
    _loadMoodData();  // Load the mood data from Firestore when the page is initialized
  }

  Future<void> _loadMoodData() async {
    final firestore = FirebaseFirestore.instance;
    final userId = "user_example_id";  // Replace with actual user ID from Firebase Auth
    final diaryCollection = firestore
        .collection('users')
        .doc(userId)
        .collection('diary_entries');

    try {
      final querySnapshot = await diaryCollection.get();
      Map<DateTime, String> moods = {};

      for (var doc in querySnapshot.docs) {
        DateTime date = (doc['date'] as Timestamp).toDate();
        String mood = doc['mood'] ?? 'happy';  // Default to 'happy' if mood is missing

        // Convert mood from text to emoji
        String emoji = _getEmojiFromMood(mood);

        moods[DateTime(date.year, date.month, date.day)] = emoji;
      }

      setState(() {
        _moodEmojis = moods;  // Update mood data
      });
    } catch (e) {
      print("Error loading mood data: $e");
    }
  }

  String _getEmojiFromMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😡';
      case 'neutral':
        return '😐';
      case 'Excited':
        return '😄';
      default:
        return '😊';  // Default emoji
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
      });
    }
  }

  Widget _buildDay(DateTime date, bool isToday) {
    String? moodEmoji = _moodEmojis[date];
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday ? Colors.blue[100] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isToday ? Colors.blue : Colors.black,
            ),
          ),
          Text(
            moodEmoji ?? '',
            style: TextStyle(fontSize: 18),  // Display the emoji for the mood
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Tracker'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: (day) {
              // Return mood emoji for the selected day (if any)
              return _moodEmojis[day] != null ? [_moodEmojis[day]!] : [];
            },
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, date, _) {
                return _buildDay(date, true);
              },
              selectedBuilder: (context, date, _) {
                return _buildDay(date, false);
              },
              defaultBuilder: (context, date, _) {
                return _buildDay(date, false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
