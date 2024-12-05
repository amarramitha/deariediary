import 'package:deariediary/routes/routes.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _quoteOfTheDay = '';
  String _userName = 'Nama Pengguna';
  String _userBio = 'Setiap hari memberikan hadiahnya masing-masing.';
  String _profileImageUrl = ''; // URL gambar profil
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _quoteOfTheDay = getQuoteOfTheDay();
    _loadUserData();
  }

  String getQuoteOfTheDay() {
    final quotes = [
      '“Hidup adalah apa yang terjadi ketika kita sibuk merencanakan hal lain.” – John Lennon',
      '“Keberhasilan adalah kemampuan untuk pergi dari kegagalan ke kegagalan tanpa kehilangan antusiasme.” – Winston Churchill',
      '“Kita tidak bisa mengubah arah angin, tetapi kita bisa mengatur layar kita untuk selalu sampai di tujuan.” – Jimmy Dean',
      '“Setiap hari adalah kesempatan baru untuk membuat perubahan dalam hidup kita.” – Unknown',
      '“Tantangan adalah kesempatan untuk tumbuh lebih kuat.” – Unknown'
    ];
    final randomIndex = DateTime.now().day % quotes.length;
    return quotes[randomIndex];
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null) {
            setState(() {
              _profileImageUrl = data['photoURL'] ?? ''; // Load avatar URL
              _userName = data['displayName'] ?? user.displayName ?? 'No Name';
              _userBio = data['bio'] ?? 'No bio available';
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update profile image callback
  void _updateProfileImage(String newImageUrl) {
    setState(() {
      _profileImageUrl = newImageUrl;
    });
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
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildProfileHeader(),
            const SizedBox(height: 20), // Reduced space here
            _buildQuoteCard(),
            const SizedBox(height: 20), // Reduced space here
            _buildMenuOptions(),
            const SizedBox(height: 20), // Reduced space here
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
          backgroundImage: _profileImageUrl.isNotEmpty
              ? NetworkImage(_profileImageUrl)
              : null,
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(_userBio, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            // Pass the callback function to the EditProfile page
            Get.to(() => EditProfile(
                  bio: _userBio,
                  onBioUpdated: _updateBio,
                  onProfileImageUpdated:
                      _updateProfileImage, // Pass image update callback
                ));
          },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.edit, color: Colors.pink[300]),
          ),
        ),
      ],
    );
  }

  // Update bio callback (fixing the variable name)
  void _updateBio(String newBio) {
    setState(() {
      _userBio = newBio;
    });
  }

  // Define the Quote Card widget
  // Define the Quote Card widget
  Widget _buildQuoteCard() {
    return Card(
      color: Colors.pink[100], // Adjust the color of the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.format_quote,
                color: Colors.pink, size: 30), // Quote icon
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _quoteOfTheDay,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Menu options under the quote card
  Widget _buildMenuOptions() {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.pink[100],
          child: ListTile(
            leading: Icon(Icons.settings, color: Colors.pink),
            title: Text('Kebijakan Privasi'),
            onTap: () {
              Get.toNamed(AppRoutes.privasi); // Navigate to Privacy Policy page
            },
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.pink[100],
          child: ListTile(
            leading: Icon(Icons.info_outline, color: Colors.pink),
            title: Text('Tentang Kami'),
            onTap: () {
              Get.toNamed(AppRoutes.about); // Navigate to About Us page
            },
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.pink[100],
          child: ListTile(
            leading: Icon(Icons.help_outline, color: Colors.pink),
            title: Text('Bantuan'),
            onTap: () {
              Get.toNamed(AppRoutes.bantuan); // Navigate to Help page
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity, // Stretch button to full width
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink[100], // Button background color
          foregroundColor: Colors.black, // Set text color to black
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        child: Text('Keluar'),
      ),
    );
  }

  void _logout() async {
    await _auth.signOut();
    Get.offAllNamed('/login');
  }
}
