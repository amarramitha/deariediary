import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bantuan'),
        backgroundColor: Colors.pink[100], // Consistent with your theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                  'Selamat datang di halaman Bantuan Dearie Diary!'),
              _buildDescription(
                  'Kami di sini untuk membantu Anda memanfaatkan semua fitur yang ada pada aplikasi kami. Jika Anda memiliki pertanyaan atau membutuhkan panduan, berikut adalah beberapa informasi yang dapat membantu Anda.'),
              _buildSectionTitle('1. Bagaimana cara membuat akun?'),
              _buildDescription(
                  'Untuk membuat akun di Dearie Diary, ikuti langkah-langkah berikut:\n'
                  '1. Buka aplikasi dan pilih Daftar.\n'
                  '2. Masukkan alamat email Anda, buat kata sandi, dan pilih nama pengguna.\n'
                  '3. Klik Daftar untuk menyelesaikan proses.\n'
                  '4. Anda akan menerima email verifikasi untuk mengonfirmasi alamat email Anda.'),
              _buildSectionTitle(
                  '2. Bagaimana cara menulis entri di buku harian?'),
              _buildDescription('Menulis entri di Dearie Diary sangat mudah:\n'
                  '1. Buka aplikasi dan login ke akun Anda.\n'
                  '2. Pilih tombol Tulis Entri.\n'
                  '3. Pilih tanggal dan mulai menulis pengalaman, perasaan, atau pikiran Anda.\n'
                  '4. Setelah selesai, tekan Simpan untuk menyimpan entri Anda.'),
              _buildSectionTitle(
                  '3. Apa itu Mood Tracker dan bagaimana cara menggunakannya?'),
              _buildDescription(
                  'Mood Tracker memungkinkan Anda untuk memantau suasana hati setiap hari:\n'
                  '1. Setelah menulis entri, Anda dapat memilih Emoji Mood untuk menggambarkan suasana hati Anda pada hari tersebut.\n'
                  '2. Pilih emoji yang sesuai dan simpan entri Anda. Emoji ini akan ditampilkan di kalender untuk memudahkan Anda melacak perubahan suasana hati Anda dari waktu ke waktu.'),
              _buildSectionTitle('4. Apa itu Fitur Sambat?'),
              _buildDescription(
                  'Fitur Sambat memberi Anda ruang pribadi untuk menulis keluhan atau perasaan tanpa takut dinilai orang lain:\n'
                  '1. Pilih Sambat dari menu utama.\n'
                  '2. Tulis keluhan atau perasaan Anda pada kolom yang tersedia.\n'
                  '3. Setelah selesai, tekan Simpan. Catatan ini hanya bisa dilihat oleh Anda dan tidak dapat diakses oleh orang lain.'),
              _buildSectionTitle(
                  '5. Bagaimana cara menghapus entri atau akun saya?'),
              _buildDescription(
                  '- Menghapus entri: Buka entri yang ingin dihapus, lalu pilih opsi Hapus di bagian bawah entri.\n'
                  '- Menghapus akun: Untuk menghapus akun, buka Pengaturan > Akun dan pilih Hapus Akun. Semua data terkait akun Anda akan dihapus secara permanen.'),
              _buildSectionTitle(
                  '6. Bagaimana cara mengakses data saya di perangkat lain?'),
              _buildDescription(
                  'Untuk mengakses entri Anda di perangkat lain, Anda perlu masuk ke akun Dearie Diary Anda. Jika Anda memilih untuk menyinkronkan entri Anda ke cloud, data akan disinkronkan dan dapat diakses di semua perangkat yang terhubung dengan akun yang sama.'),
              _buildSectionTitle(
                  '7. Apakah ada biaya untuk menggunakan aplikasi ini?'),
              _buildDescription(
                  'Dearie Diary tersedia secara gratis untuk digunakan. Beberapa fitur tambahan, seperti penyimpanan cloud dan fitur premium lainnya, mungkin tersedia melalui langganan berbayar.'),
              _buildSectionTitle('8. Bagaimana cara menghubungi tim dukungan?'),
              _buildDescription(
                  'Jika Anda memiliki pertanyaan lebih lanjut atau memerlukan bantuan, Anda dapat menghubungi tim dukungan kami melalui:\n'
                  '- Email: deariediaryofficial@gmail.com\n'
                  '- Formulir Kontak: Kunjungi halaman Kontak Kami di aplikasi.'),
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
        textAlign: TextAlign.justify, // This ensures text is justified
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Jakarta',
          color: Colors.black87, // Standard text color
        ),
      ),
    );
  }
}
