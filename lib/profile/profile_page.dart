import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';
import 'dart:async'; // Import Timer

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _quoteOfTheDay = ''; // Quote yang akan diganti
  String _bio = 'Setiap hari memberikan hadiahnya masing-masing.'; // Perkenalan default

  // Daftar quote yang akan ditampilkan secara acak
  final List<String> quotes = [
    '“Hidup adalah apa yang terjadi ketika kita sibuk merencanakan hal lain.” – John Lennon',
    '“Keberhasilan adalah kemampuan untuk pergi dari kegagalan ke kegagalan tanpa kehilangan antusiasme.” – Winston Churchill',
    '“Kita tidak bisa mengubah arah angin, tetapi kita bisa mengatur layar kita untuk selalu sampai di tujuan.” – Jimmy Dean',
    '“Setiap hari adalah kesempatan baru untuk membuat perubahan dalam hidup kita.” – Unknown',
    '“Tantangan adalah kesempatan untuk tumbuh lebih kuat.” – Unknown'
  ];

  // Mengambil quote acak berdasarkan waktu
  String getQuoteOfTheDay() {
    final randomIndex = (quotes.length * (DateTime.now().second / 60)).floor(); // Menggunakan waktu untuk mendapatkan index acak
    return quotes[randomIndex % quotes.length];
  }

  @override
  void initState() {
    super.initState();
    _quoteOfTheDay = getQuoteOfTheDay(); // Set quote awal saat halaman pertama kali dibuka

    // Timer untuk mengganti quote setiap 1 menit
    Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _quoteOfTheDay = getQuoteOfTheDay(); // Ganti quote setiap 1 menit
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> _getUserName() async {
    User? user = _auth.currentUser;
    return user?.displayName ?? 'Nama Pengguna'; // Mengambil nama pengguna jika ada
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserName(), // Mengambil name dari Firebase
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Profil')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Profil')),
            body: Center(child: Text('Terjadi kesalahan')),
          );
        }

        // Nama pengguna dari Firebase Authentication
        String name = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.pink[50],
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Information
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name, // Nama pengguna dari Firebase
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _bio, // Perkenalan yang diambil dari _bio
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    // Membuat ikon panah bisa di klik
                    InkWell(
                      onTap: () {
                        // Navigasi ke halaman edit_profile.dart
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfile(bio: _bio, onBioUpdated: _updateBio)), // Ganti dengan widget halaman EditProfile Anda
                        );
                      },
                      child: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // Statistik Mood
                Text(
                  'Statistik Mood Anda (Per Bulan):',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[300],
                  ),
                ),
                SizedBox(height: 16),
                // Mood Chart
                _buildMoodChart(),
                SizedBox(height: 30),
                // Quote of the Day
                _buildQuoteCard(),
                SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk memperbarui bio
  void _updateBio(String updatedBio) {
    setState(() {
      _bio = updatedBio;
    });
  }

  // Card untuk menampilkan quote of the day
  Widget _buildQuoteCard() {
    return Container(
      padding: EdgeInsets.all(16),
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
            ),
          ),
          SizedBox(height: 8),
          Text(
            '"$_quoteOfTheDay"', // Menampilkan quote yang berubah
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart() {
    return Container(
      padding: EdgeInsets.all(16),
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
          // Mood Stats (dummy data for the month)
          _buildMoodBar('Minggu 1', 5),
          _buildMoodBar('Minggu 2', 3),
          _buildMoodBar('Minggu 3', 4),
          _buildMoodBar('Minggu 4', 2),
        ],
      ),
    );
  }

  Widget _buildMoodBar(String week, int moodLevel) {
    // Emoji untuk setiap tingkat mood
    String moodEmoji = '';
    String moodDescription = '';
    Color moodColor = Colors.grey;

    switch (moodLevel) {
      case 5:
        moodEmoji = '😊'; // Bahagia
        moodDescription = 'Sangat Bahagia';
        moodColor = Colors.green;
        break;
      case 4:
        moodEmoji = '🙂'; // Senang
        moodDescription = 'Senang';
        moodColor = Colors.yellow;
        break;
      case 3:
        moodEmoji = '😐'; // Netral
        moodDescription = 'Netral';
        moodColor = Colors.orange;
        break;
      case 2:
        moodEmoji = '😞'; // Sedih
        moodDescription = 'Sedih';
        moodColor = Colors.red;
        break;
      default:
        moodEmoji = '😔'; // Sangat Sedih
        moodDescription = 'Sangat Sedih';
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              // Emoji
              Text(
                moodEmoji,
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 8),
              // Mood Level bar
              Container(
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: moodLevel / 5.0, // Normalize to a range of 0-1
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
}