import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _quoteOfTheDay = '';
  String _name = 'Nama Pengguna';
  String _bio = 'Setiap hari memberikan hadiahnya masing-masing.';

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

    Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _quoteOfTheDay = getQuoteOfTheDay();
        });
      }
    });
  }

  String getQuoteOfTheDay() {
    final randomIndex = (quotes.length * (DateTime.now().second / 60)).floor();
    return quotes[randomIndex % quotes.length];
  }

  Future<void> _fetchUserData() async {
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
  }

  // Method to handle logout
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
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
            const SizedBox(height: 30),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jakarta',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _bio,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: 'Jakarta',
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfile(
                  bio: _bio,
                  onBioUpdated: _updateBio,
                ),
              ),
            );
          },
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
          'Statistik Mood Anda (Per Bulan):',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.pink[300],
            fontFamily: 'Jakarta',
          ),
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quote of the Day:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink[300],
              fontFamily: 'Jakarta',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$_quoteOfTheDay"',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
              fontFamily: 'Jakarta',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoodBar('Minggu 1', 5),
          _buildMoodBar('Minggu 2', 3),
          _buildMoodBar('Minggu 3', 4),
          _buildMoodBar('Minggu 4', 2),
        ],
      ),
    );
  }

  Widget _buildMoodBar(String week, int moodLevel) {
    String moodEmoji = '';
    Color moodColor = Colors.grey;

    switch (moodLevel) {
      case 5:
        moodEmoji = '😊';
        moodColor = Colors.green;
        break;
      case 4:
        moodEmoji = '🙂';
        moodColor = Colors.yellow;
        break;
      case 3:
        moodEmoji = '😐';
        moodColor = Colors.orange;
        break;
      case 2:
        moodEmoji = '😞';
        moodColor = Colors.red;
        break;
      default:
        moodEmoji = '😔';
        moodColor = Colors.redAccent;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            week,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Jakarta',
            ),
          ),
          Row(
            children: [
              Text(
                moodEmoji,
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Container(
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  widthFactor: moodLevel / 5.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: moodColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: SizedBox(
        width: double.infinity, // Stretches the button
        child: ElevatedButton(
          onPressed: _logout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[300],
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Logout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Jakarta',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Method to handle bio update
  void _updateBio(String newBio) {
    setState(() {
      _bio = newBio;
    });
  }
}
