//사용자 정보 설정 페이지
import 'package:flutter/material.dart'; // Flutter의 기본 위젯과 머티리얼 디자인 사용을 위해 임포트
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 저장소 접근을 위해 임포트

// 사용자 정보 페이지를 나타내는 StatefulWidget
class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

// 사용자 정보 페이지의 상태를 관리하는 클래스
class _UserInfoPageState extends State<UserInfoPage> {
  // 나이, 키, 몸무게를 입력받는 컨트롤러를 선언
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // 사용자 정보를 저장하는 함수.
  void _saveUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스를 가져옴
    await prefs.setInt('age', int.parse(ageController.text)); // 나이를 저장
    await prefs.setDouble('height', double.parse(heightController.text)); // 키를 저장
    await prefs.setDouble('weight', double.parse(weightController.text)); // 몸무게를 저장
    // 정보가 저장되었다는 메시지를 화면에 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('사용자 정보가 저장되었습니다.')),
    );
  }

  // 저장된 사용자 정보를 로드하는 함수
  void _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스를 가져옴
    setState(() {
      // 저장된 나이, 키, 몸무게를 각 컨트롤러에 설정
      ageController.text = (prefs.getInt('age') ?? '').toString();
      heightController.text = (prefs.getDouble('height') ?? '').toString();
      weightController.text = (prefs.getDouble('weight') ?? '').toString();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // 위젯이 처음 생성될 때 저장된 사용자 정보를 로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단의 앱바를 정의
      appBar: AppBar(
        backgroundColor: Colors.white, // 앱바의 배경색을 흰색으로 설정
        title: Text(
          '사용자 정보', // 앱바의 제목을 설정
          style: TextStyle(
            fontFamily: 'Bebas Neue', // 폰트를 설정
            fontSize: 28.0, // 폰트 크기를 설정
            fontWeight: FontWeight.w900, // 폰트를 두껍게 설정
          ),
        ),
        iconTheme: IconThemeData(), // 아이콘 테마를 설정
      ),
      // 본문 내용을 정의
      body: Padding(
        padding: EdgeInsets.all(16.0), // 화면의 모든 면에 16.0의 여백을 줌
        child: ListView(
          children: [
            // 나이 입력 필드
            _buildTextField(
              controller: ageController,
              label: '나이',
              hintText: '나이를 입력하세요',
            ),
            SizedBox(height: 16.0), // 위젯 사이의 간격을 줌
            // 키 입력 필드
            _buildTextField(
              controller: heightController,
              label: '키 (cm)',
              hintText: '키를 입력하세요',
            ),
            SizedBox(height: 16.0),
            // 몸무게 입력 필드
            _buildTextField(
              controller: weightController,
              label: '몸무게 (kg)',
              hintText: '몸무게를 입력하세요',
            ),
            SizedBox(height: 32.0),
            // 저장 버튼
            ElevatedButton(
              onPressed: _saveUserInfo, // 버튼을 눌렀을 때 사용자 정보를 저장
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼의 배경색을 설정
                elevation: 4.0, // 버튼의 그림자 높이를 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // 버튼의 모서리를 둥글게 만듬
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼의 상하 여백을 설정
              ),
              child: Text(
                '저장', // 버튼에 표시될 텍스트
                style: TextStyle(
                  fontFamily: 'Bebas Neue', // 폰트를 설정
                  fontSize: 20.0, // 폰트 크기를 설정
                  fontWeight: FontWeight.bold, // 폰트를 굵게 설정
                  color: Colors.white, // 텍스트의 색상을 설정
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 텍스트 입력 필드를 생성하는 위젯
  Widget _buildTextField({
    required TextEditingController controller, // 입력 값을 제어하는 컨트롤러
    required String label, // 필드의 레이블 텍스트
    String? hintText, // 힌트 텍스트
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0), // 좌우 여백을 줌
      decoration: BoxDecoration(
        color: Colors.grey[100], // 배경색을 연한 회색으로 설정
        borderRadius: BorderRadius.circular(16.0), // 모서리를 둥글게 만듬
      ),
      child: TextField(
        controller: controller, // 컨트롤러를 연결
        decoration: InputDecoration(
          labelText: label, // 레이블 텍스트를 설정
          labelStyle: TextStyle(
            fontFamily: 'Roboto', // 폰트를 설정
            fontWeight: FontWeight.w600, // 폰트를 약간 두껍게 설정
            fontSize: 16.0, // 폰트 크기를 설정
          ),
          hintText: hintText, // 힌트 텍스트를 설정
          border: InputBorder.none, // 기본 입력창 테두리를 제거
        ),
        keyboardType: TextInputType.number, // 숫자 입력 전용 키보드를 사용
      ),
    );
  }
}
