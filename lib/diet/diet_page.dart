// 식단 관리 페이지
import 'dart:convert'; // JSON 데이터를 인코딩 및 디코딩하기 위해 사용
import 'package:flutter/material.dart'; // Flutter의 기본 위젯들을 제공하는 패키지
import 'package:shared_preferences/shared_preferences.dart'; // 데이터 저장을 위한 패키지
import 'add_diet_page.dart'; // 식단 추가 페이지를 위한 선언
import 'diet_detail_page.dart'; // 식단 상세 페이지를 위한 선언
import '../user_info_page.dart'; // 마이페이지로 이동하기 위한 파일 추가
import 'package:oss_team_project_app/utils/json_loader.dart'; // JSON 로더 임포트


// DietPage는 사용자가 식단을 관리할 수 있는 화면을 제공함
class DietPage extends StatefulWidget {
  @override
  _DietPageState createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  List<Map<String, dynamic>> diets = []; // 저장된 식단 목록을 저장하는 리스트

  @override
  void initState() {
    super.initState();
    _loadDiets();
    _initializeJsonData(); // JSON 데이터 초기화
  }

// JSON 데이터 로드 및 저장
  List<Map<String, dynamic>> jsonData = [];
  void _initializeJsonData() async {
    jsonData = await loadJsonData('밥류.json');
  }


  // 저장된 식단 데이터를 SharedPreferences에서 불러오는 함수
  void _loadDiets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기
    String? savedDiets = prefs.getString('diets'); // 'diets' 키로 저장된 데이터를 가져옴
    if (savedDiets != null) {
      setState(() {
        diets = List<Map<String, dynamic>>.from(json.decode(savedDiets) as List); // JSON 데이터를 디코딩하여 diets 리스트에 저장함
      });
    }
  }

  // 현재 식단 목록을 SharedPreferences에 저장하는 함수
  void _saveDiets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기
    await prefs.setString('diets', json.encode(diets)); // diets 리스트를 JSON 문자열로 인코딩하여 저장함
  }

  // 새로운 식단을 추가하는 함수
  void _addNewDiet(Map<String, dynamic> diet) {
    setState(() {
      diets.add(diet); // diets 리스트에 새로운 식단 추가
      _saveDiets(); // 변경된 diets 리스트를 저장함
    });
  }

  // 기존 식단을 업데이트하는 함수
  void _updateDiet(int index, Map<String, dynamic> updatedDiet) {
    setState(() {
      diets[index] = updatedDiet; // 지정된 인덱스의 식단을 업데이트함
      _saveDiets(); // 변경된 diets 리스트를 저장함
    });
  }

  // 식단을 제거하는 함수
  void _removeDiet(int index) {
    setState(() {
      diets.removeAt(index); // 지정된 인덱스의 식단을 리스트에서 제거함
      _saveDiets(); // 변경된 diets 리스트를 저장함
    });
  }

  // 식단 추가 페이지로 이동하는 함수
  void _goToAddDietPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDietPage(), // AddDietPage로 이동함
        fullscreenDialog: true, // 전체 화면 다이얼로그로 표시함
      ),
    );
    if (result != null) {
      _addNewDiet(result); // AddDietPage에서 반환된 식단을 추가함
    }
  }

  // 식단 상세 페이지로 이동하는 함수
  void _goToDietDetailPage(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DietDetailPage(
          diet: diets[index], // 선택된 식단 데이터를 전달함
          onSave: (updatedDiet) {
            _updateDiet(index, updatedDiet); // 식단이 업데이트되면 호출됨
          },
          onDelete: () {
            _removeDiet(index); // 식단이 삭제되면 호출됨
          },
        ),
        fullscreenDialog: true, // 전체 화면 다이얼로그로 표시함
      ),
    );
    if (result != null) {
      setState(() {
        _saveDiets(); // 변경된 diets 리스트를 저장함
      });
    }
  }

  // 총 섭취 칼로리를 계산하는 함수
  int _calculateTotalCalories() {
    num totalCalories = 0;
    for (var diet in diets) {
      for (var food in diet['foods']) {
        totalCalories += (food['calories'] ?? 0); // 각 음식의 칼로리를 합산함
      }
    }
    return totalCalories.toInt(); // 총 칼로리를 정수로 반환함
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '식단 관리', // 앱바 제목 설정
          style: TextStyle(
            fontFamily: 'Bebas Neue', // 폰트 적용
            fontSize: 28.0, // 폰트 크기 설정
            fontWeight: FontWeight.w900, // 폰트 두께 설정
            color: Colors.black, // 폰트 색상 설정
          ),
        ),
        backgroundColor: Colors.white, // 앱바 배경색 설정
        iconTheme: IconThemeData(color: Colors.black), // 앱바 아이콘 색상 설정
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserInfoPage(), // UserInfoPage로 이동함
                  fullscreenDialog: true, // 전체 화면 다이얼로그로 표시함
                ),
              );
            },
            icon: const Icon(Icons.person, color: Colors.black), // 사람 아이콘 설정
          ),
        ],
      ),
      body: diets.isEmpty
          ? Center(
        child: Text(
          '등록된 식단이 없습니다.', // 식단이 없을 때 표시할 메시지
          style: TextStyle(
            fontFamily: 'Roboto', // 폰트 설정
            fontSize: 18.0, // 글자 크기 설정
            fontWeight: FontWeight.w600, // 글자 두께 설정
            color: Colors.black54, // 글자 색상 설정
          ),
        ),
      )
          : Padding(
        padding:
        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // 전체 패딩 설정
        child: Column(
          children: [
            Text(
              '총 섭취 칼로리: ${_calculateTotalCalories()} kcal', // 총 칼로리 표시
              style: TextStyle(
                fontFamily: 'Roboto', // 폰트 설정
                fontSize: 20.0, // 글자 크기 설정
                fontWeight: FontWeight.bold, // 글자 두께 설정
                color: Colors.black, // 글자 색상 설정
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: diets.length, // 리스트 아이템 수 설정
                itemBuilder: (context, index) {
                  final diet = diets[index]; // 현재 인덱스의 식단 데이터 가져오기
                  return GestureDetector(
                    onTap: () {
                      _goToDietDetailPage(index); // 식단을 탭하면 상세 페이지로 이동함
                    },
                    child: Card(
                      elevation: 4.0, // 카드 그림자 높이 설정
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0), // 카드 여백 설정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0), // 카드 모서리 둥글게 설정
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0), // 리스트 타일 내부 여백 설정
                        title: Text(
                          diet['name'], // 식단 이름 표시
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, // 글자 두께 설정
                            fontSize: 18.0, // 글자 크기 설정
                            fontFamily: 'Roboto', // 폰트 설정
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddDietPage, // 플로팅 버튼을 누르면 식단 추가 페이지로 이동함
        backgroundColor: Colors.blueAccent, // 버튼 배경색 설정
        child: const Icon(
          Icons.add, // 추가 아이콘 설정
          color: Colors.white, // 아이콘 색상 설정
        ),
      ),
    );
  }
}
