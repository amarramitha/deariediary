import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodTrackerPage extends StatefulWidget {
  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  Map<DateTime, String> _selectedMoods =
      {}; // Menyimpan mood berdasarkan tanggal
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMoodsFromFirestore(); // Memuat mood dari Firestore
  }

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Memuat data mood dari Firestore
  Future<void> _loadMoodsFromFirestore() async {
    if (userId == null) return;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('diary_entries')
          .orderBy('date', descending: true) // Mengurutkan berdasarkan tanggal
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

  // Mendapatkan mood untuk tanggal tertentu
  String? _getMoodForDate(DateTime date) {
    for (DateTime key in _selectedMoods.keys) {
      if (isSameDay(key, date)) {
        return _selectedMoods[key];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
          ),
        ],
      ),
    );
  }

  // Membuat tampilan hari pada kalender
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
            ? RichText(
                text: TextSpan(
                  text: mood,
                  style: GoogleFonts.notoColorEmoji(
                    textStyle: TextStyle(
                      fontSize: 24,
                      color:
                          isToday || isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              )
            : Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  color: isToday || isSelected ? Colors.white : Colors.black,
                ),
              ),
      ),
    );
  }
}
