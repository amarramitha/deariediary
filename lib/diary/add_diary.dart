import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deariediary/diary/dashboard_diary.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:deariediary/controller/diary_controller.dart';

class AddDiaryPage extends StatefulWidget {
  final String? entryId;
  final String? existingTitle;
  final String? existingContent;

  const AddDiaryPage({
    this.entryId,
    this.existingTitle,
    this.existingContent,
    Key? key,
  }) : super(key: key);

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final DiaryController diaryController = Get.put(DiaryController());
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _mood;
  String? selectedMoodEmoji;
  DateTime selectedDate = DateTime.now();

  final List<String> moods = [
    '😊',
    '😢',
    '😠',
    '😍',
    '😞',
    '😁',
    '😌',
    '😖',
    '😭',
    '😕',
    '😎',
    '🤣',
    '🥳',
    '😴',
    '🤒',
    '🤔',
    '🥱',
    '🥴',
    '🤑',
    '😮‍💨',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.entryId != null) {
      _titleController.text = widget.existingTitle ?? '';
      _contentController.text = widget.existingContent ?? '';
    }
  }

  Future<void> _saveDiaryEntry(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (widget.entryId == null) {
        await diaryController.addDiaryEntry(
          context,
          title: _titleController.text,
          content: _contentController.text,
          mood: _mood ?? '',
          date: selectedDate,
        );
      } else {
        await diaryController.updateDiaryEntry(
          context,
          entryId: widget.entryId!,
          title: _titleController.text,
          content: _contentController.text,
          mood: _mood ?? '',
          date: selectedDate,
        );
      }

      Get.offAll(() => DashboardDiary());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save diary entry: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectMood(BuildContext context) async {
    final selectedMood = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Bagaimana mood kamu hari ini?'),
          content: SizedBox(
            width: double.maxFinite, // Pastikan dialog menyesuaikan lebar layar
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Jumlah kolom dalam grid
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: moods.length,
              itemBuilder: (BuildContext gridContext, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(dialogContext)
                        .pop(moods[index]); // Menutup dialog
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        moods[index],
                        style: GoogleFonts.notoColorEmoji(
                            fontSize: 30), // Font emoji
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

    if (selectedMood != null) {
      setState(() {
        selectedMoodEmoji = selectedMood;
        _mood = selectedMood;
      });
      debugPrint("Mood terpilih: $_mood");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveDiaryEntry(context),
          ),
        ],
      ),
      body: Card(
        color: Colors.pink[50], // Background warna pink untuk Card utama
        margin: EdgeInsets.zero, // Card memenuhi seluruh halaman
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Tidak ada border radius
        ),
        elevation: 0, // Hilangkan bayangan agar rata
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Semua elemen rata kiri
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_today),
                        ),
                        Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _selectMood(context),
                      child: Text(
                        selectedMoodEmoji ?? '😊', // Menampilkan emoji mood
                        style: GoogleFonts.notoColorEmoji(
                            fontSize: 30), // Ukuran emoji mood
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Bagaimana hari kamu?',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontFamily: 'Jakarta'),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter a title' : null,
                  style: const TextStyle(fontFamily: 'Jakarta'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Yuk bagikan ceritamu disini!',
                    border: InputBorder.none, // Hapus garis bawah
                    alignLabelWithHint: true,
                    hintStyle: TextStyle(fontFamily: 'Jakarta'),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter content' : null,
                  maxLines: 6,
                  style: const TextStyle(fontFamily: 'Jakarta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
