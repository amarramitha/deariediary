import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodTrackerPage extends StatefulWidget {
  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  Map<DateTime, String> _moodData = {}; // Store mood data by date
  DateTime _selectedDay = DateTime.now();
  FirebaseFirestore _db = FirebaseFirestore.instance;
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _fetchMoodData(); // Fetch mood data from Firebase
  }

  Future<void> _fetchMoodData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        isLoading.value = true;

        // Fetch diary entries from Firebase
        final snapshot = await _db
            .collection('users')
            .doc(currentUser.uid)
            .collection('diary_entries')
            .orderBy('date', descending: true) // Sort by date
            .get();

        // Create a map to store moods by date
        Map<DateTime, String> fetchedMoodData = {};

        // Process each document to get mood and date
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final date = (data['date'] as Timestamp)
              .toDate(); // Convert Timestamp to DateTime
          final mood = data['mood'];

          // Save mood by date (only date, without time)
          fetchedMoodData[DateTime(date.year, date.month, date.day)] = mood;
        }

        // Update _moodData with the fetched data
        setState(() {
          _moodData = fetchedMoodData;
        });
      } catch (e) {
        print("Error fetching mood data: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  String _getMoodForDate(DateTime date) {
    return _moodData[date] ?? 'neutral'; // Default to 'neutral' if no mood
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Tracker'),
      ),
      body: Column(
        children: [
          // Display mood calendar
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            eventLoader: (day) {
              return [_getMoodForDate(day)]; // Load mood for the day
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                String mood = _getMoodForDate(date); // Get mood for the day
                return Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    mood == 'neutral' ? '${date.day}' : moodEmoji(mood),
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Show selected mood
          Text(
            'Mood for ${_selectedDay.toLocal()} is: ${_getMoodForDate(_selectedDay)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String moodEmoji(String mood) {
    switch (mood) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'neutral':
      default:
        return '😐';
    }
  }
}
