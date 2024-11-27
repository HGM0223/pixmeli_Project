import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'calendar_screen.dart';

class SignInScreen extends StatelessWidget {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  SignInScreen({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user != null) {
          // TODO: 유저 정보를 백엔드에 저장하는 로직 추가
          //백엔드에 저장하기 위해 유저 정보 가져오기
          String? uid = user.uid;
          String? email = user.email;

          // Firestore호출
          await fireStore.collection('User').doc(uid).set({
            "userId": uid,
            "userEmail": email,
          }).catchError((error) {
            print("Failed to add user: $error");
          });

          print("User ${user.displayName} logged in!");

          // 로그인 성공 시 다음 화면으로 전환
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CalendarScreen(),
            ),
          );
        }
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
    }
  }


  Widget buildSocialButton({
    required String logoPath,
    required String text,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75, // 양옆 여백을 더 늘림
        height: MediaQuery.of(context).size.height * 0.06, // 높이 조정
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              logoPath,
              width: MediaQuery.of(context).size.width * 0.05,
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double height = constraints.maxHeight;
          double width = constraints.maxWidth;

          return Container(
            width: width,
            height: height,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: height * 0.1), // 상단 여백을 늘림
                // 로고와 앱 이름을 Row로 배치
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Pixmeli_Logo.png',
                      width: width * 0.06,
                      height: height * 0.06,
                    ),
                    SizedBox(width: width * 0.02),
                    Text(
                      '픽멜리',
                      style: TextStyle(
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.05), // 로고와 콘텐츠 사이 여백 증가
                // 본문 텍스트
                Column(
                  children: [
                    Text(
                      '계정을 만들어주세요',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      '로그인을 위해 이메일을 입력해주세요',
                      style: TextStyle(
                        fontSize: width * 0.035,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04), // 이메일 입력칸 위 여백
                // 이메일 입력 및 확인 버튼
                Column(
                  children: [
                    Container(
                      width: width * 0.75, // 양옆 여백을 더 늘림
                      height: height * 0.06,
                      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDFDFDF)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'email@domain.com',
                        style: TextStyle(
                          color: const Color(0xFF828282),
                          fontSize: width * 0.035,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Container(
                      width: width * 0.75, // 양옆 여백을 더 늘림
                      height: height * 0.06,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAD934),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04), // 구분선 위 여백 증가
                // 구분선
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE6E6E6),
                        margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      ),
                    ),
                    Text(
                      'or',
                      style: TextStyle(
                        fontSize: width * 0.035,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE6E6E6),
                        margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04), // 소셜 버튼 위 여백 증가
                // 소셜 로그인 버튼
                Column(
                  children: [
                    buildSocialButton(
                      logoPath: 'assets/images/googleLogo.png',
                      text: '구글로 시작하기',
                      onPressed: () async {
                        await signInWithGoogle(context);
                      },
                      context: context,
                    ),
                    SizedBox(height: height * 0.02),
                    buildSocialButton(
                      logoPath: 'assets/images/kakaoLogo.png',
                      text: '카카오로 시작하기',
                      onPressed: () {
                        print("카카오 로그인 클릭");
                      },
                      context: context,
                    ),
                    SizedBox(height: height * 0.02),
                    buildSocialButton(
                      logoPath: 'assets/images/naverLogo.png',
                      text: '네이버로 시작하기',
                      onPressed: () {
                        print("네이버 로그인 클릭");
                      },
                      context: context,
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: height * 0.03),
                  child: SizedBox(
                    width: width * 0.75, // Aligns text width with buttons
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'By clicking continue, you agree to our ',
                            style: TextStyle(
                              color: const Color(0xFF828282),
                              fontSize: width * 0.03,
                            ),
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              fontSize: width * 0.03,
                            ),
                          ),
                          TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              color: const Color(0xFF828282),
                              fontSize: width * 0.03,
                            ),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: const Color(0xFF828282),
                              fontSize: width * 0.03,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}