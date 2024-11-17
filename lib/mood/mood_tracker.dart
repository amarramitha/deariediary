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
  Map<DateTime, String> _selectedMoods = {};
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
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
    '🤑',
    '😮‍💨',
  ];

  @override
  void initState() {
    super.initState();
    _loadMoodsFromFirestore();
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

    // Memastikan tanggal yang dipilih tidak lebih dari hari ini
    if (_selectedDay.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Tidak dapat memilih mood untuk tanggal besok.')),
      );
      return;
    }

    final String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay);

    try {
      // Update mood di Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc(dateKey)
          .set({'mood': mood, 'date': _selectedDay});

      // Setelah disimpan, reload mood dari Firestore
      _loadMoodsFromFirestore();
    } catch (e) {
      print("Error saving mood: $e");
    }
  }

  void _showEmojiDialog() {
    String? existingMood = _getMoodForDate(_selectedDay);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double dialogWidth = MediaQuery.of(context).size.width * 0.8;
        double dialogHeight = MediaQuery.of(context).size.height * 0.4;

        return AlertDialog(
          title: Text("Pilih atau Edit Mood Kamu"),
          content: Container(
            width: dialogWidth,
            height: dialogHeight,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: _availableEmojis.length,
              itemBuilder: (context, index) {
                final emoji = _availableEmojis[index];
                final isSelected = emoji == existingMood;

                return GestureDetector(
                  onTap: () {
                    // Segera perbarui mood untuk tanggal yang dipilih
                    setState(() {
                      _selectedMoods[_selectedDay] = emoji;
                    });

                    // Simpan ke Firestore
                    _addMoodForSelectedDay(emoji);

                    // Tutup dialog
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          text: emoji,
                          style: GoogleFonts.notoColorEmoji(
                            textStyle: TextStyle(
                              fontSize: 40,
                            ),
                          ),
                        ),
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
              // Tampilkan dialog emoji hanya jika tanggal yang dipilih valid
              if (!_selectedDay.isAfter(DateTime.now())) {
                _showEmojiDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Belum dapat memilih mood untuk tanggal ini.')),
                );
              }
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
