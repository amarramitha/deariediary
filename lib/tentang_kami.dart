import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang Kami'),
        backgroundColor: Colors.pink[100], // Consistent with your theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(), // Image added here
              _buildSectionTitle('Tentang Dearie Diary'),
              _buildDescription(
                  'Dearie Diary adalah aplikasi diary mobile yang memudahkan pengguna mencatat pengalaman, pikiran, dan perasaan mereka dengan praktis. '
                  'Dilengkapi dengan fitur pencatatan harian, mood tracker untuk memantau suasana hati, serta fitur sambat yang menyediakan ruang pribadi bagi pengguna untuk mengekspresikan perasaan tanpa penilaian orang lain. '
                  'Dengan tampilan kalender terintegrasi, Dearie Diary membantu pengguna mengelola catatan secara kronologis, menjadikannya alat yang personal untuk refleksi diri sehari-hari.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Image.asset(
        'images/deariediary.png', // Replace with your image path
        height: 200, // Adjust the height of the image
        width: double.infinity, // Make the image take full width
        fit: BoxFit.cover, // To ensure the image scales correctly
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontFamily: 'Jakartamedium',
          fontWeight: FontWeight.bold,
          color: Colors.pink[300], // Consistent with the theme
        ),
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      child: Text(
        description,
        textAlign: TextAlign.justify, // This ensures the text is justified
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Jakarta',
          color: Colors.black87, // Standard text color
        ),
      ),
    );
  }
}
