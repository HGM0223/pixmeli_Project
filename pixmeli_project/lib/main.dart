import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart'; // 로컬 데이터 초기화
import 'screens/splash_screen.dart';
import 'screens/calendar_screen.dart'; // 추가한 캘린더 화면

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await Firebase.initializeApp(); // Firebase 초기화
  await FirebaseAuth.instance.signOut(); // 로그아웃을 명시
  await initializeDateFormatting('ko', null); // 한국어 로컬 데이터 초기화

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // 초기 화면 설정
      routes: {
        '/': (context) => const SplashScreen(), // 스플래시 화면
        '/calendar_screen': (context) => const CalendarScreen(), // 캘린더 화면
      },
    );
  }
}

