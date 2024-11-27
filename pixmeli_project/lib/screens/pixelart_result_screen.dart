import 'dart:math';
import 'package:flutter/material.dart';

class PixelartResultScreen extends StatelessWidget {
  final DateTime selectedDay;
  final String diaryContent;
  final String imageUrl;

  PixelartResultScreen({
    Key? key,
    required this.selectedDay,
    required this.diaryContent,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          // 상단 헤더
          Container(
            height: screenHeight * 0.15,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE6E6E6), width: 1), // 아래쪽에 회색 선 추가
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 37,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF333333)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  left: 55,
                  top: 47,
                  child: Transform.rotate(
                    angle: pi / 2,
                    child: Image.asset(
                      'assets/images/Pixmeli_Logo.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
                Positioned(
                  left: 95,
                  top: 49,
                  child: Text(
                    '${selectedDay.month}월 ${selectedDay.day}일',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  top: 33,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        color: Color(0xFFFBBC05),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 중간 섹션: 이미지와 일기 내용
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 1), // 아래쪽 패딩만 줄임
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 저장된 사진 표시
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 일기 내용 텍스트 박스
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    height: 160, // 고정된 높이
                    child: SingleChildScrollView(
                      child: Text(
                        diaryContent.isNotEmpty ? diaryContent : "일기 내용이 없습니다.",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단 저장 버튼
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            width: double.infinity,
            color: Colors.white,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // 저장 로직 추가 (필요시)
                  // calendar_screen.dart로 이동
                  Navigator.pushNamed(context, '/calendar_screen');
                  print("확인 버튼 클릭");
                },
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFAD934),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '확인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
