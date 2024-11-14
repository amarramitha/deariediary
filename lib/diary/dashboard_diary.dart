import 'package:deariediary/feeds/add_post.dart';
import 'package:deariediary/feeds/post_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deariediary/feeds/post_feed.dart';
import 'package:deariediary/mood/mood_tracker.dart';
import 'package:deariediary/profile/profile_page.dart';
import 'diary_page.dart';
import 'package:deariediary/controller/dashboard_controller.dart';

class DashboardDiary extends StatelessWidget {
  final DashboardController dashboardController =
      Get.put(DashboardController());

  final List<Widget> _pages = [
    DiaryPage(),
    PostFeedPage(),
    MoodTrackerPage(),
    ProfilePage(), // Mengirimkan name ke ProfilePage
  ];

  final List<String> _titles = [
    'Diary',
    'Sambat',
    'Mood Tracker',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          return AppBar(
            title: Text(_titles[dashboardController.selectedIndex.value]),
            backgroundColor: const Color.fromARGB(255, 255, 185, 210),
          );
        }),
      ),
      body: Obx(() {
        return IndexedStack(
          index: dashboardController.selectedIndex.value,
          children: _pages,
        );
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: dashboardController.selectedIndex.value,
          onTap: dashboardController.changePage,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
            BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Sambat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.sentiment_satisfied), label: 'Mood Tracker'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'Profil'),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        if (dashboardController.selectedIndex.value == 1) {
          return FloatingActionButton(
            onPressed: () {
              Get.to(AddPostPage()); // Menavigasi ke halaman pembuatan postingan
            },
            child: Icon(Icons.add),
          );
        }
        return SizedBox.shrink(); // Tidak menampilkan FAB jika bukan di halaman Post Feed
      }),
    );
  }
}
