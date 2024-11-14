// textediting_controller.dart
import 'package:flutter/material.dart';

class BioController {
  // TextEditingController untuk mengelola input bio
  TextEditingController bioController = TextEditingController();

  // Variabel untuk menyimpan nilai bio yang diperbarui
  String _bio = "";

  // Fungsi untuk memperbarui nilai bio
  void updateBio(String newBio) {
    _bio = newBio; // Memperbarui bio
  }

  // Getter untuk mengambil bio terbaru
  String get bio => _bio;

  // Fungsi untuk memulai dengan nilai bio default
  void setDefaultBio(String defaultBio) {
    _bio = defaultBio;
    bioController.text = defaultBio; // Set nilai default ke controller
  }
}
