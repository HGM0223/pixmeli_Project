import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'happy_diary_screen.dart';
import 'write_screen.dart';
import 'diary_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _diaryCount = 0;

  final Set<String> _diaryDays = {}; // 일기가 있는 날의 문서 이름 저장

  @override
  void initState() {
    super.initState();
    _fetchDiaryCount();
    _fetchDiaryData(); // Firestore에서 데이터 가져오기
  }

  Future<void> _fetchDiaryCount() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('User')
            .doc(uid)
            .collection('Diaries')
            .get();
        setState(() {
          _diaryCount = snapshot.docs.length;
        });
      } catch (e) {
        print('Error fetching diary count: $e');
        setState(() {
          _diaryCount = 0;
        });
      }
    }
  }

  Future<void> _fetchDiaryData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('User')
            .doc(uid)
            .collection('Diaries')
            .get();

        final Set<String> diaryDays = {};
        for (var doc in snapshot.docs) {
          diaryDays.add(doc.id); // 문서 이름(날짜) 저장
        }

        setState(() {
          _diaryDays.clear();
          _diaryDays.addAll(diaryDays); // _diaryDays에 모든 날짜 추가
        });
      } catch (e) {
        print('Error fetching diary data: $e');
      }
    }
  }

  Future<void> _handleDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final docId = '${selectedDay.year}${selectedDay.month.toString().padLeft(2, '0')}${selectedDay.day.toString().padLeft(2, '0')}';
      final diaryDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(uid)
          .collection('Diaries')
          .doc(docId)
          .get();

      if (diaryDoc.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryScreen(
              selectedDay: selectedDay,
              uid: uid,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WriteScreen(
              selectedDay: selectedDay,
              uid: uid,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(screenWidth),
      body: Column(
        children: [
          // 상단 영역
          Container(
            height: screenHeight * 0.22,
            decoration: const BoxDecoration(color: Colors.white),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      padding: EdgeInsets.only(top: screenHeight * 0.13),
                      icon: const Icon(Icons.menu, color: Color(0xFF333333)),
                      iconSize: screenWidth * 0.06,
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
                Image.asset(
                  'assets/images/Pixmeli_Logo.png',
                  height: screenHeight * 0.05,
                ),
                IconButton(
                  padding: EdgeInsets.only(top: screenHeight * 0.1),
                  icon: const Icon(Icons.search, color: Color(0xFF333333)),
                  iconSize: screenWidth * 0.06,
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // 캘린더 영역
          Container(
            height: screenHeight * 0.70,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: screenWidth * 0.001,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 0.5,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: _buildCalendar(screenWidth, screenHeight),
              ),
            ),
          ),

          // 하단 영역
          Container(
            height: screenHeight * 0.04,
            decoration: const BoxDecoration(color: Colors.white),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '지금까지 몇 개의 일기를 썼을까요',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '$_diaryCount개',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(double screenWidth) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFFDED5E)),
            child: Text(
              '메뉴',
              style: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.05,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('계정관리'),
            onTap: () {
              // 계정 관리 기능 추가
            },
          ),
          ListTile(
            leading: const Icon(Icons.sentiment_satisfied_alt),
            title: const Text('긍정 일기 모아보기'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HappyDiaryScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('타임캡슐 만들기'),
            onTap: () {
              // 타임캡슐 기능 추가
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('공유 일기장 만들기'),
            onTap: () {
              // 공유 일기장 기능 추가
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('화면 잠금'),
            onTap: () {
              // 화면 잠금 기능 추가
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('환경설정'),
            onTap: () {
              // 환경 설정 기능 추가
            },
          ),
        ],
      ),
    );
  }

  TableCalendar _buildCalendar(double screenWidth, double screenHeight) {
    return TableCalendar(
      locale: 'ko_KR',
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _handleDaySelected,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextFormatter: (date, locale) =>
            DateFormat.yMMMM('ko').format(date),
        titleTextStyle: TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        leftChevronIcon: Icon(Icons.chevron_left,
            color: Colors.black, size: screenWidth * 0.05),
        rightChevronIcon: Icon(Icons.chevron_right,
            color: Colors.black, size: screenWidth * 0.05),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: const Color(0xFF828282),
          fontSize: screenWidth * 0.03,
        ),
        weekendStyle: TextStyle(
          color: const Color(0xFF828282),
          fontSize: screenWidth * 0.03,
        ),
      ),
      calendarStyle: CalendarStyle(
        defaultDecoration: const BoxDecoration(
          color: Colors.white,
        ),
        defaultTextStyle: TextStyle(
          color: const Color(0xFF828282),
          fontSize: screenWidth * 0.03,
        ),
        todayDecoration: const BoxDecoration(
          color: Color(0xFFFDED5E),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Color(0xFF7A76F5),
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final docId = '${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';
          final hasDiary = _diaryDays.contains(docId); // 날짜가 _diaryDays에 포함되었는지 확인

          return Center(
            child: Container(
              width: screenWidth * 0.07,
              height: screenWidth * 0.07,
              decoration: BoxDecoration(
                color: hasDiary ? const Color(0xFFFDED5E) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}', // 날짜 표시
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: hasDiary ? Colors.black : const Color(0xFF828282),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
