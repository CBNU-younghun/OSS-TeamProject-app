// 메인 페이지
import 'package:flutter/material.dart'; // Flutter의 기본 위젯과 머티리얼 디자인 사용
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart'; // 뉴모픽 디자인 사용
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 저장소 접근을 위한 패키지
import 'diet/diet_page.dart'; // 식단 관리 페이지 임포트
import 'routine/routine_page.dart'; // 루틴 관리 페이지 임포트
import 'exercise/exercise_info_page.dart'; // 운동 정보 페이지 임포트
import 'user_info_page.dart'; // 사용자 정보 페이지 임포트
import 'splash_screen.dart'; // 스플래시 스크린 임포트

// 앱의 시작점
void main() {
  runApp(HealthManagementApp()); // HealthManagementApp 위젯 실행
}

// 건강 관리 앱의 메인 클래스
class HealthManagementApp extends StatelessWidget {
  final Color backgroundColor = Colors.white; // 앱의 배경색 설정
  final Color accentColor = Colors.blue; // 강조 색상 설정

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      title: 'FITNESS 앱', // 앱 제목 설정(임시)
      theme: NeumorphicThemeData(
        baseColor: backgroundColor, // 기본 배경색
        accentColor: accentColor, // 강조 색상
        defaultTextColor: Colors.black, // 기본 텍스트 색상
      ),
      themeMode: ThemeMode.light, // 항상 라이트 모드 사용
      home: SplashScreen(), // 앱 시작 시 SplashScreen 위젯 표시
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
    );
  }
}

// 초기 화면을 보여주는 위젯 클래스
class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

// InitialScreen의 상태를 관리하는 클래스
class _InitialScreenState extends State<InitialScreen> {
  bool _isUserInfoSaved = false; // 사용자 정보 저장 여부를 확인하는 변수

  @override
  void initState() {
    super.initState();
    _checkUserInfoStatus(); // 위젯 초기화 시 사용자 정보 저장 상태 확인
  }

  // 사용자 정보가 저장되어 있는지 확인하는 함수
  Future<void> _checkUserInfoStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 획득
    setState(() {
      // 나이, 키, 몸무게 정보가 모두 저장되어 있는지 확인
      _isUserInfoSaved = prefs.containsKey('age') &&
          prefs.containsKey('height') &&
          prefs.containsKey('weight');
    });
  }

  @override
  Widget build(BuildContext context) {
    // 사용자 정보가 저장되어 있으면 메인 페이지로, 아니면 사용자 정보 입력 페이지로 이동
    return _isUserInfoSaved ? HomePage() : UserInfoInputPage();
  }
}

// 사용자 정보 입력 페이지를 나타내는 위젯 클래스
class UserInfoInputPage extends StatefulWidget {
  @override
  _UserInfoInputPageState createState() => _UserInfoInputPageState();
}

// UserInfoInputPage의 상태를 관리하는 클래스
class _UserInfoInputPageState extends State<UserInfoInputPage> {
  final TextEditingController ageInputController = TextEditingController(); // 나이 입력 컨트롤러
  final TextEditingController heightInputController = TextEditingController(); // 키 입력 컨트롤러
  final TextEditingController weightInputController = TextEditingController(); // 몸무게 입력 컨트롤러

  // 사용자 정보를 로컬 저장소에 저장하는 함수
  Future<void> _saveUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 획득
    await prefs.setInt('age', int.parse(ageInputController.text)); // 나이 저장
    await prefs.setDouble('height', double.parse(heightInputController.text)); // 키 저장
    await prefs.setDouble('weight', double.parse(weightInputController.text)); // 몸무게 저장
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), // 저장 후 메인 페이지로 이동
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 앱바 배경색 설정
        title: Text(
          '사용자 정보 입력',
          style: TextStyle(
            fontFamily: 'Bebas Neue', // 폰트 패밀리 설정
            fontSize: 28.0, // 폰트 크기 설정
            fontWeight: FontWeight.w900, // 폰트 굵기 설정
          ),
        ),
        iconTheme: IconThemeData(), // 아이콘 테마 설정
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // 화면 여백 설정
        child: ListView(
          children: [
            // 나이 입력 필드
            _buildTextField(
              controller: ageInputController,
              label: '나이',
              hintText: '나이를 입력하세요',
            ),
            SizedBox(height: 16.0), // 입력 필드 간 간격
            // 키 입력 필드
            _buildTextField(
              controller: heightInputController,
              label: '키 (cm)',
              hintText: '키를 입력하세요',
            ),
            SizedBox(height: 16.0), // 입력 필드 간 간격
            // 몸무게 입력 필드
            _buildTextField(
              controller: weightInputController,
              label: '몸무게 (kg)',
              hintText: '몸무게를 입력하세요',
            ),
            SizedBox(height: 32.0), // 버튼과 입력 필드 간 간격
            // 저장 버튼
            ElevatedButton(
              onPressed: _saveUserInfo, // 버튼 클릭 시 사용자 정보 저장 함수 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // 버튼 배경색
                elevation: 4.0, // 버튼 그림자 높이
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // 버튼 모서리 둥글게 설정
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 내부 여백 설정
              ),
              child: Text(
                '저장하고 시작하기',
                style: TextStyle(
                  fontFamily: 'Bebas Neue', // 폰트 패밀리 설정
                  fontSize: 20.0, // 폰트 크기 설정
                  fontWeight: FontWeight.bold, // 폰트 굵기 설정
                  color: Colors.white, // 폰트 색상 설정
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 텍스트 입력 필드를 생성하는 함수
  Widget _buildTextField({
    required TextEditingController controller, // 입력 컨트롤러
    required String label, // 레이블 텍스트
    String? hintText, // 힌트 텍스트
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0), // 입력 필드 내부 여백 설정
      decoration: BoxDecoration(
        color: Colors.grey[100], // 입력 필드 배경색 설정
        borderRadius: BorderRadius.circular(16.0), // 입력 필드 모서리 둥글게 설정
      ),
      child: TextField(
        controller: controller, // 입력 컨트롤러 연결
        decoration: InputDecoration(
          labelText: label, // 레이블 텍스트 설정
          labelStyle: TextStyle(
            fontFamily: 'Roboto', // 폰트 패밀리 설정
            fontWeight: FontWeight.w600, // 폰트 굵기 설정
            fontSize: 16.0, // 폰트 크기 설정
            color: Colors.black87, // 폰트 색상 설정
          ),
          hintText: hintText, // 힌트 텍스트 설정
          hintStyle: TextStyle(
            fontFamily: 'Roboto', // 폰트 패밀리 설정
            fontSize: 14.0, // 폰트 크기 설정
            color: Colors.black54, // 폰트 색상 설정
          ),
          border: InputBorder.none, // 기본 입력창 테두리 제거
        ),
        keyboardType: TextInputType.number, // 숫자 입력 전용 키보드 사용
      ),
    );
  }
}

// 메인 페이지를 나타내는 위젯 클래스
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// HomePage의 상태를 관리하는 클래스
class _HomePageState extends State<HomePage> {
  MenuOption _selectedOption = MenuOption.Diet; // 현재 선택된 메뉴 옵션, 기본값은 식단
  late PageController _pageController; // 페이지 컨트롤러 추가

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedOption.index); // 초기 페이지 설정
  }

  @override
  void dispose() {
    _pageController.dispose(); // 페이지 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _selectedOption = MenuOption.values[index]; // 페이지 변경 시 선택된 메뉴 업데이트
          });
        },
        children: [
          DietPage(), // 식단 관리 페이지
          RoutinePage(), // 루틴 관리 페이지
          ExerciseInfoPage(), // 운동 정보 페이지
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: NeumorphicTheme.baseColor(context), // 바탕색 설정
        selectedItemColor: NeumorphicTheme.isUsingDark(context)
            ? Colors.blueAccent
            : Colors.blue, // 선택된 아이템 색상
        unselectedItemColor:
        NeumorphicTheme.isUsingDark(context) ? Colors.white70 : Colors.grey, // 선택되지 않은 아이템 색상
        currentIndex: _selectedOption.index, // 현재 선택된 인덱스 설정
        onTap: (int index) {
          setState(() {
            _selectedOption = MenuOption.values[index]; // 선택된 메뉴 옵션 변경
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ); // 페이지 이동 애니메이션 추가
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant), // 아이콘 설정
            label: '식단', // 메뉴 레이블
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list), // 아이콘 설정
            label: '루틴', // 메뉴 레이블
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center), // 아이콘 설정
            label: '운동 정보', // 메뉴 레이블
          ),
        ],
      ),
    );
  }
}

// 메뉴 옵션을 정의하는 열거형(enum)
enum MenuOption { Diet, Routine, ExerciseInfo }
