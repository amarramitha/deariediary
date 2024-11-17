import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodTrackerPage extends StatefulWidget {
  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  Map<DateTime, String> _selectedMoods = {}; // Data emoji
  DateTime _selectedDay = DateTime.now(); // Tanggal dipilih
  DateTime _focusedDay = DateTime.now(); // Tanggal fokus
  final List<String> _availableEmojis = [
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
  ];

  @override
  void initState() {
    super.initState();
    _loadMoodsFromFirestore(); // Load data mood saat aplikasi mulai
  }

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _loadMoodsFromFirestore() async {
    if (userId == null) return;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('moods')
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

  Future<void> _addMoodForSelectedDay(String mood) async {
    if (userId == null) return;
    final String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc(dateKey)
          .set({'mood': mood, 'date': _selectedDay});

      setState(() {
        _selectedMoods[_selectedDay] = mood;
        _focusedDay = _selectedDay; // Refresh tampilan kalender
      });
    } catch (e) {
      print("Error saving mood: $e");
    }
  }

  void _showEmojiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pilih mood kamu"),
          content: Container(
            height: 230,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: _availableEmojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Update emoji langsung di UI
                      _selectedMoods[_selectedDay] = _availableEmojis[index];
                      _focusedDay = _selectedDay; // Perbarui tampilan kalender
                    });
                    _addMoodForSelectedDay(_availableEmojis[index]);
                    Navigator.of(context).pop(); // Tutup dialog
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _availableEmojis[index],
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

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
              _showEmojiDialog();
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

  Widget _buildDay(DateTime date,
      {bool isToday = false, bool isSelected = false}) {
    final mood = _getMoodForDate(date);
    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? Colors.blueAccent
            : (isSelected ? Colors.pink[100] : Colors.transparent),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          mood ?? '${date.day}',
          style: TextStyle(
            fontSize: mood != null ? 24 : 14,
            color: isToday || isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
