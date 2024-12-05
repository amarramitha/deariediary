import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodTrackerPage extends StatefulWidget {
  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  Map<DateTime, String> _selectedMoods = {}; // Stores mood by date
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMoodsFromFirestore(); // Load moods from Firestore
  }

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Load mood data from Firestore
  Future<void> _loadMoodsFromFirestore() async {
    if (userId == null) return;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('diary_entries')
          .orderBy('date', descending: true) // Sort by date
          .get();

      setState(() {
        _selectedMoods = {
          for (var doc in querySnapshot.docs)
            (doc['date'] as Timestamp).toDate(): doc['mood']
        };
      });
    } catch (e) {
      print("Error loading moods: $e");
    }
  }

  // Get the mood for a particular date
  String? _getMoodForDate(DateTime date) {
    for (DateTime key in _selectedMoods.keys) {
      if (isSameDay(key, date)) {
        return _selectedMoods[key];
      }
    }
    return null;
  }

  // Count moods
  Map<String, int> _getMoodCount() {
    Map<String, int> moodCount = {};
    _selectedMoods.values.forEach((mood) {
      moodCount[mood] = (moodCount[mood] ?? 0) + 1;
    });
    return moodCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x64F6DADA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, _) => _buildDay(date),
                  todayBuilder: (context, date, _) =>
                      _buildDay(date, isToday: true),
                  selectedBuilder: (context, date, _) =>
                      _buildDay(date, isSelected: true),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false, // Remove format button
                  titleCentered: true, // Center the month title
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  weekendStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              _buildMoodStatistics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDay(DateTime date,
      {bool isToday = false, bool isSelected = false}) {
    final mood = _getMoodForDate(date);
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.pink[100]?.withOpacity(0.5)
            : (isToday
                ? Colors.blueAccent.withOpacity(0.3)
                : Colors.transparent),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: mood != null
            ? Text(
                mood,
                style: GoogleFonts.notoColorEmoji(
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: isToday || isSelected ? Colors.white : Colors.black,
                  ),
                ),
              )
            : Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16,
                  color: isToday || isSelected ? Colors.white : Colors.black,
                ),
              ),
      ),
    );
  }

  Widget _buildMoodStatistics() {
    Map<String, int> moodCount = _getMoodCount();
    int maxCount = moodCount.values.isEmpty
        ? 1
        : moodCount.values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Statistics:',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Jakartamedium',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          for (var entry in moodCount.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text('${entry.key}:',
                      style: GoogleFonts.notoColorEmoji(
                          textStyle: TextStyle(
                        fontSize: 16,
                      ))),
                  SizedBox(width: 10),
                  Expanded(
                    child: Stack(
                      children: [
                        // Background bar
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // Foreground bar
                        FractionallySizedBox(
                          widthFactor: entry.value / maxCount,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 204, 125, 184),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${entry.value}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
