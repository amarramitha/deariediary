import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String postContent;
  final String? imageUrl;
  final String userName; // Nama pengguna
  final String? userProfileUrl; // URL gambar profil pengguna

  final Function onDelete;

  PostCard({
    required this.postContent,
    this.imageUrl,
    required this.userName,
    this.userProfileUrl,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Menghilangkan margin antar card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            color: Colors.grey.shade300, width: 1), // Outline di atas dan bawah
      ),
      color: Colors.transparent, // Card transparan
      elevation: 0, // Menghilangkan bayangan
      child: Container(
        width: double.infinity, // Memastikan card memenuhi lebar layar
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian atas: Profile dan nama, dengan titik tiga menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Gambar profil
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: userProfileUrl != null
                            ? NetworkImage(userProfileUrl!)
                            : AssetImage('assets/default_profile.png')
                                as ImageProvider, // Gambar default jika tidak ada
                      ),
                      SizedBox(width: 8),
                      // Nama pengguna
                      Text(userName,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // Menu titik tiga untuk edit dan hapus
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Hapus'),
                        ),
                      ];
                    },
                    child: Icon(Icons.more_vert), // Titik tiga menu
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Konten post
              Text(postContent, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
