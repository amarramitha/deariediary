import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _quoteOfTheDay = '';
  String _name = 'Nama Pengguna';
  String _bio = 'Setiap hari memberikan hadiahnya masing-masing.';
  List<int> _weeklyMoodData = [0, 0, 0, 0];

  final List<String> quotes = [
    '“Hidup adalah apa yang terjadi ketika kita sibuk merencanakan hal lain.” – John Lennon',
    '“Keberhasilan adalah kemampuan untuk pergi dari kegagalan ke kegagalan tanpa kehilangan antusiasme.” – Winston Churchill',
    '“Kita tidak bisa mengubah arah angin, tetapi kita bisa mengatur layar kita untuk selalu sampai di tujuan.” – Jimmy Dean',
    '“Setiap hari adalah kesempatan baru untuk membuat perubahan dalam hidup kita.” – Unknown',
    '“Tantangan adalah kesempatan untuk tumbuh lebih kuat.” – Unknown'
  ];

  @override
  void initState() {
    super.initState();
    _quoteOfTheDay = getQuoteOfTheDay();
    _fetchUserData();
    _fetchMoodData();
  }

  String getQuoteOfTheDay() {
    final randomIndex = DateTime.now().day % quotes.length;
    return quotes[randomIndex];
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          _name = userData['name'] ?? 'Nama Pengguna';
          _bio = userData['bio'] ??
              'Setiap hari memberikan hadiahnya masing-masing.';
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _fetchMoodData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot moodEntries = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('diary_entries')
            .orderBy('date', descending: true)
            .get();

        List<int> weeklyMood = [0, 0, 0, 0];

        for (var entry in moodEntries.docs) {
          Timestamp timestamp = entry['date'];
          int moodLevel = entry['moodLevel'];
          DateTime entryDate = timestamp.toDate();
          int weekNumber =
              ((DateTime.now().difference(entryDate).inDays) / 7).floor();

          if (weekNumber >= 0 && weekNumber < 4) {
            weeklyMood[weekNumber] = (weeklyMood[weekNumber] + moodLevel) ~/ 2;
          }
        }

        setState(() {
          _weeklyMoodData = weeklyMood;
        });
      }
    } catch (e) {
      print("Error fetching mood data: $e");
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Get.offNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildMoodStatistics(),
            const SizedBox(height: 30),
            _buildQuoteCard(),
            const SizedBox(height: 30),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(_bio, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
        InkWell(
          onTap: () =>
              Get.to(() => EditProfile(bio: _bio, onBioUpdated: _updateBio)),
          child: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMoodStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Mood Anda (Per Minggu):',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink[300]),
        ),
        const SizedBox(height: 16),
        _buildMoodChart(),
      ],
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quote of the Day:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[300])),
          const SizedBox(height: 8),
          Text('"$_quoteOfTheDay"',
              style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildMoodChart() {
    // Uncomment to use a line chart instead of a list-based chart
    /*
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              _weeklyMoodData.length,
              (index) => FlSpot(index.toDouble(), _weeklyMoodData[index].toDouble()),
            ),
            isCurved: true,
            barWidth: 4,
            colors: [Colors.pinkAccent],
          ),
        ],
      ),
    );
    */

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_weeklyMoodData.length, (index) {
          return _buildMoodBar('Minggu ${index + 1}', _weeklyMoodData[index]);
        }),
      ),
    );
  }

  Widget _buildMoodBar(String week, int moodLevel) {
    String moodEmoji = moodLevel >= 4
        ? '😊'
        : moodLevel >= 3
            ? '🙂'
            : moodLevel >= 2
                ? '😞'
                : '😔';
    Color moodColor = moodLevel >= 4
        ? Colors.green
        : moodLevel >= 3
            ? Colors.yellow
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(week,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(moodEmoji, style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text('$moodLevel/5',
                  style: TextStyle(
                      color: moodColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _logout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink[200],
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text('Logout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  void _updateBio(String newBio) {
    setState(() {
      _bio = newBio;
    });
  }
}
