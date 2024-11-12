import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiaryService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Function to add a diary entry
  Future<void> addDiaryEntry(String title, String content) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('diary_entries')
          .add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save diary entry: $e');
    }
  }

  // Function to get diary entries for the authenticated user
  Stream<List<Map<String, dynamic>>> getDiaryEntries() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('diary_entries')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'title': data['title'],
                'content': data['content'],
                'timestamp': data['timestamp'],
              };
            }).toList());
  }

  // Function to update an existing diary entry
  Future<void> updateDiaryEntry(
      String entryId, String title, String content) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('diary_entries')
          .doc(entryId)
          .update({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('User is not authenticated');
    }
  }

  // Function to delete a diary entry
  Future<void> deleteDiaryEntry(String entryId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('diary_entries')
          .doc(entryId)
          .delete();
    } else {
      throw Exception('User is not authenticated');
    }
  }
}
