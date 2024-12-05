import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kebijakan Privasi'),
        backgroundColor: Colors.pink[100], // Consistent with your theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Kebijakan Privasi'),
              _buildDescription('Terakhir diperbarui: 5 Desember 2024\n'),
              _buildSectionTitle('Persyaratan Usia'),
              _buildDescription(
                  'Anda harus berusia 16 tahun atau lebih untuk menggunakan layanan ini.'),
              _buildSectionTitle('Data yang Kami Kumpulkan'),
              _buildDescription(
                  'Kami mengumpulkan dan memproses data pribadi berikut:\n'
                  '- Alamat email (diperlukan untuk pembuatan akun dan komunikasi)\n'
                  '- Alamat IP (untuk tujuan keamanan)\n'
                  '- Entri buku harian dan pengaturan akun\n'
                  '- Data analitik penggunaan\n'
                  '- Data terkait mood tracker dan fitur sambat'),
              _buildSectionTitle('Dasar Hukum Pemrosesan'),
              _buildDescription('Kami memproses data Anda berdasarkan:\n'
                  '- Pemenuhan kontrak (penyediaan layanan aplikasi Dearie Diary)\n'
                  '- Persetujuan Anda (untuk fitur opsional seperti mood tracker dan sambat)\n'
                  '- Kepentingan yang sah (keamanan, peningkatan layanan)'),
              _buildSectionTitle('Bagaimana Kami Menggunakan Data Anda'),
              _buildDescription('Data Anda digunakan untuk:\n'
                  '- Menyediakan dan memelihara Layanan\n'
                  '- Autentikasi dan keamanan akun\n'
                  '- Komunikasi tentang pembaruan layanan\n'
                  '- Peningkatan layanan dan analisis penggunaan aplikasi'),
              _buildSectionTitle('Penyimpanan Data dan Keamanan'),
              _buildDescription(
                  'Secara default, catatan harian Anda disimpan secara lokal di perangkat Anda.\n\n'
                  'Jika Anda memilih untuk menggunakan akun cloud dan/atau menyinkronkan entri Anda ke cloud, data Anda akan ditransfer dan disimpan di server yang terletak di [lokasi server sesuai kebijakan penyimpanan]. Data ditransfer menggunakan enkripsi (SSL). Kami menerapkan langkah-langkah keamanan yang sesuai untuk melindungi data Anda.'),
              _buildSectionTitle('Hak-Hak Anda'),
              _buildDescription('Di bawah GDPR, Anda memiliki hak untuk:\n'
                  '- Mengakses data pribadi Anda\n'
                  '- Mengoreksi data yang tidak akurat\n'
                  '- Meminta penghapusan data\n'
                  '- Menarik persetujuan\n'
                  '- Portabilitas data\n'
                  '- Menolak pemrosesan data'),
              _buildSectionTitle('Layanan Pihak Ketiga'),
              _buildDescription(
                  'Kami menggunakan layanan pihak ketiga untuk tujuan tertentu, termasuk:\n'
                  '- Google Analytics (statistik penggunaan)\n'
                  '- Google AdMob (periklanan)\n'
                  '- Firebase Crashlytics (pelaporan crash)'),
              _buildSectionTitle('Hubungi Kami'),
              _buildDescription(
                  'Untuk pertanyaan terkait privasi atau untuk menggunakan hak Anda, hubungi kami di deariediaryofficial@gmail.com'),
            ],
          ),
        ),
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
          fontWeight: FontWeight.bold,
          fontFamily: 'Jakartamedium',
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
        textAlign: TextAlign.justify, // Justifying the text alignment
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Jakarta',
          color: Colors.black87, // Standard text color
        ),
      ),
    );
  }
}
