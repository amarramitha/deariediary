import 'package:deariediary/bantuan.dart';
import 'package:deariediary/kebijakan_privasi.dart';
import 'package:deariediary/register.dart';
import 'package:deariediary/tentang_kami.dart';
import 'package:get/get.dart';
import 'package:deariediary/diary/add_diary.dart';
import 'package:deariediary/diary/dashboard_diary.dart';
import 'package:deariediary/login.dart';
import 'package:deariediary/splash_screen.dart';
import 'package:deariediary/feeds/add_post.dart';
import 'package:deariediary/feeds/post_feed.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String addDiary = '/add-diary';
  static const String addPost = '/add-post';
  static const String postFeed = '/post-feed';
  static const String bantuan = '/bantuan';
  static const String privasi = '/privasi';
  static const String about = '/about';

  static final routes = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => Login(),
    ),
    GetPage(
      name: register,
      page: () => Register(),
    ),
    GetPage(
      name: home,
      page: () => DashboardDiary(),
    ),
    GetPage(
      name: addDiary,
      page: () => AddDiaryPage(),
    ),
    GetPage(
      name: addPost, // Rute untuk AddPostPage
      page: () => AddPostPage(),
    ),
    GetPage(
      name: postFeed,
      page: () => PostFeedPage(),
    ),
    GetPage(
      name: bantuan,
      page: () => HelpPage(),
    ),
    GetPage(
      name: privasi,
      page: () => PrivacyPolicyPage(),
    ),
    GetPage(
      name: about,
      page: () => AboutUsPage(),
    ),
  ];
}
