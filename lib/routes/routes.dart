import 'package:deariediary/register.dart';
import 'package:get/get.dart';
import 'package:deariediary/diary/add_diary.dart';
import 'package:deariediary/diary/dashboard_diary.dart';
import 'package:deariediary/login.dart';
import 'package:deariediary/splash_screen.dart';
import 'package:deariediary/feeds/add_post.dart';
import 'package:deariediary/feeds/post_feed.dart';
import 'package:deariediary/mood/mood_tracker.dart'; // Import halaman MoodTrackerPage

class AppRoutes {
  // Mendefinisikan rute yang ada di aplikasi
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/'; // DashboardDiary
  static const String addDiary = '/add-diary';
  static const String addPost = '/add-post';
  static const String postFeed = '/post-feed';
  static const String moodTracker = '/mood-tracker'; // Rute untuk MoodTrackerPage

  // Daftar rute yang ada di aplikasi
  static final routes = [
    // Rute untuk Splash Screen
    GetPage(
      name: splash,
      page: () => SplashScreen(),
    ),
    // Rute untuk Login
    GetPage(
      name: login,
      page: () => Login(),
    ),
    // Rute untuk Register
    GetPage(
      name: register,
      page: () => Register(),
    ),
    // Rute untuk DashboardDiary (halaman utama)
    GetPage(
      name: home,
      page: () => DashboardDiary(),
    ),
    // Rute untuk menambahkan catatan diary
    GetPage(
      name: addDiary,
      page: () => AddDiaryPage(),
    ),
    // Rute untuk menambahkan post feed
    GetPage(
      name: addPost, 
      page: () => AddPostPage(),
    ),
    // Rute untuk halaman Feed Post
    GetPage(
      name: postFeed,
      page: () => PostFeedPage(),
    ),
    // Rute untuk halaman Mood Tracker
    GetPage(
      name: moodTracker,
      page: () => MoodTrackerPage(), // Halaman MoodTrackerPage
    ),
  ];
}
