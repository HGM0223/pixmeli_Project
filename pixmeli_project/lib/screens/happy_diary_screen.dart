import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'diary_screen.dart'; // 날짜 포맷용

class HappyDiaryScreen extends StatefulWidget {
  const HappyDiaryScreen({super.key});

  @override
  _HappyDiaryScreenState createState() => _HappyDiaryScreenState();
}

class _HappyDiaryScreenState extends State<HappyDiaryScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid; // 현재 로그인된 사용자의 UID

  // Firestore에서 긍정적인 일기 가져오기
  Future<List<Map<String, dynamic>>> _fetchPositiveDiaries() async {
    if (uid == null) return [];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(uid)
          .collection('Diaries')
          .where('isPositive', isEqualTo: true)
          .orderBy('date', descending: true) // 최신순으로 정렬
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching positive diaries: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0, // 그림자 제거
        backgroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0, // 타이틀과 왼쪽 아이콘 간의 간격을 줄임
        title: Row(
          children: [
            Transform.rotate(
              angle: 90 * 3.1415926535897932 / 180, // 로고 90도 회전
              child: Image.asset(
                'assets/images/Pixmeli_Logo.png',
                height: screenWidth * 0.07,
              ),
            ),
            const SizedBox(width: 8), // 이미지와 텍스트 간격
            const Text(
              '긍정 일기 모아보기',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        leading: IconButton(
          padding: EdgeInsets.zero, // 아이콘 버튼 패딩 제거하여 왼쪽 간격 최소화
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8), // 하단 선 높이
          child: Container(
            color: Colors.grey, // 하단 선 색상
            height: 0.7,
          ),
        ),
      ),
      body: Column(
        children: [
          // 중간 메뉴 부분
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "행복했던 날을 보여줄게요",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "즐거운 기억을 갖고 다음달도 픽멜리와 함께 많은 추억을 \n기록해보세요",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey),
                ),
                const SizedBox(height: 6), // 구분선 제거 후 여백 추가
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchPositiveDiaries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('일기를 불러오는 중 오류가 발생했습니다.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('긍정 일기가 없습니다.'));
                }

                final diaries = snapshot.data!;

                return ListView.builder(
                  itemCount: diaries.length,
                  itemBuilder: (context, index) {
                    final diary = diaries[index];
                    final dateString = diary['date'] as String? ?? '';
                    DateTime? date;
                    try {
                      date = DateTime.parse(dateString);
                    } catch (e) {
                      date = DateTime.now();
                    }
                    final image = diary['imageUrl'] ?? 'assets/images/default_image.png';
                    final content = diary['content'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        // `DiaryScreen`으로 이동하며 필요한 데이터 전달
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiaryScreen(
                              selectedDay: date!, // 선택된 날짜
                              uid: uid!, // 현재 사용자 UID
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenWidth * 0.03,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                  child: Image.network(
                                    image,
                                    width: screenWidth * 0.2,
                                    height: screenWidth * 0.2,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.05),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        date != null
                                            ? DateFormat('yyyy년 MM월 dd일').format(date)
                                            : '날짜 없음',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: screenWidth * 0.02),
                                      Text(
                                        content,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );

              },
            ),
          ),
        ],
      ),
    );
  }
}
