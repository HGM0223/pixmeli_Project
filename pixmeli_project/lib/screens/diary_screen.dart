import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DiaryScreen extends StatefulWidget {
  final DateTime selectedDay;
  final String uid; // CalendarScreen에서 전달받은 UID

  const DiaryScreen({
    Key? key,
    required this.selectedDay,
    required this.uid,
  }) : super(key: key);

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  String? imageUrl;
  String? diaryContent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDiaryData();
  }

  Future<void> _fetchDiaryData() async {
    try {
      // 날짜를 기반으로 문서 ID 생성
      final docId = '${widget.selectedDay.year}${widget.selectedDay.month.toString().padLeft(2, '0')}${widget.selectedDay.day.toString().padLeft(2, '0')}';

      // Firestore에서 데이터 가져오기
      final docSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.uid) // CalendarScreen에서 전달받은 UID 사용
          .collection('Diaries')
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        setState(() {
          imageUrl = data?['imageUrl'];
          diaryContent = data?['content'] ?? '내용이 없습니다.';
          isLoading = false;
        });
      } else {
        setState(() {
          diaryContent = '일기를 찾을 수 없습니다.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        diaryContent = '데이터를 불러오는 중 오류가 발생했습니다.';
        isLoading = false;
      });
    }
  }

  Future<void> _deleteDiary(BuildContext context) async {
    try {
      // Firestore에서 현재 날짜의 일기 삭제
      final docId = '${widget.selectedDay.year}${widget.selectedDay.month.toString().padLeft(2, '0')}${widget.selectedDay.day.toString().padLeft(2, '0')}';
      await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.uid) // CalendarScreen에서 전달받은 UID 사용
          .collection('Diaries')
          .doc(docId)
          .delete();

      // 삭제 완료 후 캘린더 화면으로 이동
      Navigator.pop(context);
      Navigator.pushNamed(context, '/calendar_screen');
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일기 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 상태 표시
          : Column(
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
                  child: Image.asset(
                    'assets/images/Pixmeli_Logo.png',
                    width: 30,
                    height: 30,
                  ),
                ),
                Positioned(
                  left: 95,
                  top: 49,
                  child: Text(
                    '${widget.selectedDay.month}월 ${widget.selectedDay.day}일',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  right: 20, // 오른쪽 정렬
                  top: 48,   // 적절한 높이로 조정
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/calendar_screen');
                    },
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        color: Color(0xFFFBBC05), // 주황색 글자
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl!,
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
                        diaryContent ?? '일기 내용이 없습니다.',
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
          // 하단 삭제 및 수정 버튼
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: double.infinity,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 삭제 버튼
                GestureDetector(
                  onTap: () async {
                    await _deleteDiary(context);
                  },
                  child: const Text(
                    '삭제',
                    style: TextStyle(
                      color: Color(0xFFFBBC05), // 주황색 글자
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // 수정 버튼
                GestureDetector(
                  onTap: () {
                    //수정을 위한 로직 축가
                  },
                  child: const Text(
                    '수정',
                    style: TextStyle(
                      color: Color(0xFFFBBC05), // 주황색 글자
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
