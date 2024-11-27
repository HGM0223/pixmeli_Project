import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixmeli_project/screens/pixelart_result_screen.dart';

class WriteScreen extends StatelessWidget {
  final DateTime selectedDay;
  final String uid;
  final TextEditingController diaryController = TextEditingController();

  WriteScreen({Key? key, required this.selectedDay, required this.uid}) : super(key: key);

  /// 감정 분석 및 요약 수행
  Future<Map<String, dynamic>> analyzeAndSummarizeDiary(String diaryContent) async {
    const String apiKey = "apiKey";
    const String apiUrl = "https://api.openai.com/v1/chat/completions";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-4",
          "messages": [
            {
              "role": "system",
              "content": "You are an expert assistant specializing in emotion analysis and text summarization."
            },
            {
              "role": "user",
              "content": """
다음 일기의 감정을 분석하고 요약해주세요.
1. 긍정적이면 "isPositive: true"를, 부정적이면 "isPositive: false"를 반환해주세요.
2. 일기에서 핵심 내용을 하나 뽑아 요약해주세요.
일기: $diaryContent
결과 형식:
isPositive: true
summary: 요약된 문장
"""
            }
          ],
          "max_tokens": 100,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final result = data['choices'][0]['message']['content'].trim();

        final isPositiveMatch = RegExp(r'isPositive:\s*(true|false)').firstMatch(result);
        final summaryMatch = RegExp(r'summary:\s*(.+)').firstMatch(result);

        return {
          "isPositive": isPositiveMatch?.group(1) == 'true',
          "summary": summaryMatch?.group(1)?.trim() ?? "요약 실패",
        };
      } else {
        throw Exception("GPT API Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("GPT API 호출 실패: $e");
    }
  }

  /// Firestore에 저장
  Future<void> saveDiary(String diaryContent, Map<String, dynamic> analysisResult, String? imageUrl) async {
    final fireStore = FirebaseFirestore.instance;
    try {
      // 날짜 기반 문서 ID 생성 (YYYYMMDD 형식)
      String docId = "${selectedDay.year}${selectedDay.month.toString().padLeft(2, '0')}${selectedDay.day.toString().padLeft(2, '0')}";

      // Firestore 경로 설정
      final diaryCollection = fireStore.collection('User').doc(uid).collection('Diaries');

      // 중복 확인
      final existingDoc = await diaryCollection.doc(docId).get();
      if (existingDoc.exists) {
        throw Exception("이미 해당 날짜에 작성된 일기가 있습니다.");
      }
      print({
        'date': selectedDay.toIso8601String(),
        'content': diaryContent,
        'summary': analysisResult['summary'],
        'isPositive': analysisResult['isPositive'],
        'imageUrl': imageUrl ?? 'No Image URL',
      });


      // 일기 저장
      await diaryCollection.doc(docId).set({
        'date': selectedDay.toIso8601String(), // ISO 8601 형식으로 날짜 저장
        'content': diaryContent,
        'summary': analysisResult['summary'],
        'isPositive': analysisResult['isPositive'],
        'imageUrl': imageUrl,
      });
    } catch (e) {
      throw Exception("Firestore 저장 실패: $e");
    }
  }

  /// DALL-E를 사용해 Pixel Art 생성
  Future<String?> generatePixelArtUsingDalle(String summary) async {
    const String apiKey = "apiKey";
    const String apiUrl = "https://api.openai.com/v1/images/generations";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "dall-e-3",
          "prompt": "Please illustrate \"$summary\" as a single cute pixel art illustration. Make it adorable. Don't add any speech bubbles or text in the image.",
          "n": 1,
          "size": "1024x1024",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['data'][0]['url']; // 이미지 URL 반환
      } else {
        // 에러 발생 시 상태 코드와 메시지 출력
        print("DALL-E API Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("DALL-E API 호출 실패: $e");
      return null;
    }
  }

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
          // 중간 섹션: 일기 입력
          Container(
            height: screenHeight * 0.50,
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: diaryController,
                      decoration: InputDecoration(
                        hintText: '일기를 작성하세요',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      expands: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Button(
                  onCreateDiary: () async {
                    final diaryContent = diaryController.text;
                    if (diaryContent.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("내용을 입력해주세요!")),
                      );
                      return;
                    }
                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );
                      final analysisResult = await analyzeAndSummarizeDiary(diaryContent);
                      final imageUrl = await generatePixelArtUsingDalle(analysisResult['summary']);
                      print("Generated Image URL: $imageUrl");
                      await saveDiary(diaryContent, analysisResult, imageUrl);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PixelartResultScreen(
                            selectedDay: selectedDay, // 날짜 전달
                            diaryContent: diaryContent, // 일기 내용 전달
                            imageUrl: imageUrl ?? "", // 이미지 URL 전달 (null일 경우 빈 문자열)
                          ),
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("오류 발생: $e")),
                      );
                    }
                  },
                  onComplete: () {
                    print("작성 완료 버튼 클릭!");
                  },
                ),
              ],
            ),
          ),
          // 하단 섹션
          Container(
            height: screenHeight * 0.35,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class Button extends StatelessWidget {
  final VoidCallback onCreateDiary;
  final VoidCallback onComplete;

  const Button({
    Key? key,
    required this.onCreateDiary,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onCreateDiary,
          child: Container(
            width: 132,
            height: 50,
            decoration: ShapeDecoration(
              color: const Color(0xFFFAD934),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
            ),
            child: const Center(
              child: Text(
                '그림 일기 만들기',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        const SizedBox(width: 27),
        GestureDetector(
          onTap: onComplete,
          child: Container(
            width: 132,
            height: 50,
            decoration: ShapeDecoration(
              color: const Color(0xFFDFDFDF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
            ),
            child: const Center(
              child: Text(
                '작성 완료',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
