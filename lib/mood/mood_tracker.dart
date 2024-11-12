import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodTrackerPage extends StatefulWidget {
  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  late Map<DateTime, String> _selectedMoods; // Store moods as emojis
  late DateTime _selectedDay; // The selected day in calendar
  late DateTime _focusedDay; // Focused day for calendar

  // Available emojis and their associated colors (9 emojis with their colors)
  final List<Map<String, dynamic>> _availableEmojis = [
    {'emoji': '😊', 'color': Colors.yellow},
    {'emoji': '😢', 'color': Colors.blue},
    {'emoji': '😐', 'color': Colors.grey},
    {'emoji': '😍', 'color': Colors.pink},
    {'emoji': '😡', 'color': Colors.red},
    {'emoji': '🥺', 'color': Colors.orange},
    {'emoji': '🤣', 'color': Colors.green},
    {'emoji': '😎', 'color': Colors.cyan},
    {'emoji': '🥳', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _selectedMoods = {};
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  // Function to handle mood selection for a date
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _showEmojiDialog(); // Show emoji dialog when a day is selected
  }

  // Function to show emoji selection dialog
  void _showEmojiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 250, // Adjusted height to accommodate 9 emojis comfortably
            width: double.maxFinite, // Make dialog width full
            decoration: BoxDecoration(
              color: Colors.pink[50], // Soft pink background for dialog
              borderRadius: BorderRadius.circular(20),
            ),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 emojis per row
                childAspectRatio: 1.0, // Aspect ratio for each emoji
                crossAxisSpacing: 10.0, // Space between columns
                mainAxisSpacing: 10.0, // Space between rows
              ),
              itemCount: _availableEmojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _addMoodForSelectedDay(_availableEmojis[index]['emoji']);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Light white background for emoji box
                      border: Border.all(color: Colors.pink[100]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _availableEmojis[index]['emoji'],
                        style: TextStyle(
                          fontSize: 40, // Emoji size
                          color: _availableEmojis[index]['color'], // Emoji color
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

  // Function to handle adding a mood for the selected date
  void _addMoodForSelectedDay(String? mood) {
    setState(() {
      // Add mood for the selected day
      _selectedMoods[_selectedDay] = mood!;
    });
  }

  // Custom function to display custom icons (emoji) on the calendar
  String? _getMoodForDate(DateTime date) {
    return _selectedMoods[date];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Calendar widget
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            calendarBuilders: CalendarBuilders(
              // Custom builder to display emoji on the day number without the dot
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
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDay(DateTime date , bool isToday) {
    final mood = _getMoodForDate(date);
    Color emojiColor = Colors.black; // Default color for non-selected days

    // If mood is selected for the day, get the corresponding color
    if (mood != null) {
      emojiColor = _availableEmojis.firstWhere((emoji) => emoji['emoji'] == mood)['color'];
    }

    return Container(
      decoration: BoxDecoration(
        color: isToday ? Colors.pink[300] : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 50, // Increased max width
            maxHeight: 50, // Increased max height
          ),
          child: FittedBox(
            child: Text(
              mood ?? '${date.day}', // Display emoji or day number
              style: TextStyle(
                color: isToday ? Colors.white : emojiColor, // Apply color to the emoji
                fontSize: mood != null ? 20 : 14, // Adjust size dynamically
              ),
              textAlign: TextAlign.center, // Ensure text is centered
              overflow: TextOverflow.ellipsis, // Handle overflow
            ),
          ),
        ),
      ),
    );
  }
}
