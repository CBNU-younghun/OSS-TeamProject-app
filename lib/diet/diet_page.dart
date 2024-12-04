import 'dart:convert'; // JSON 데이터를 인코딩 및 디코딩하기 위해 사용
import 'package:flutter/material.dart'; // Flutter의 기본 위젯들을 제공하는 패키지
import 'package:shared_preferences/shared_preferences.dart'; // 데이터 저장을 위한 패키지
import 'add_diet_page.dart'; // 식단 추가 페이지를 위한 선언
import 'diet_detail_page.dart'; // 식단 상세 페이지를 위한 선언
import '../user_info_page.dart'; // 마이페이지로 이동하기 위한 파일 추가
import 'package:oss_team_project_app/utils/json_loader.dart'; // JSON 로더 임포트
import 'package:intl/intl.dart'; // 날짜 형식을 위해 사용
import 'package:fl_chart/fl_chart.dart'; // 차트 표현을 위해 사용

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
      diet['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now()); // 식단에 추가한 날짜를 추가함
      diets.insert(0, diet); // diets 리스트에 새로운 식단을 맨 위에 추가
      _saveDiets(); // 변경된 diets 리스트를 저장함
    });
  }

  // 기존 식단을 업데이트하는 함수
  void _updateDiet(int index, Map<String, dynamic> updatedDiet) {
    setState(() {
      updatedDiet['date'] = diets[index]['date']; // 기존 날짜 유지
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

  // 오늘 섭취한 총 칼로리를 계산하는 함수
  int _calculateTotalCalories() {
    num totalCalories = 0;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    for (var diet in diets) {
      if (diet['date'] == today) { // 오늘 날짜의 식단만 합산
        for (var food in diet['foods']) {
          totalCalories += (food['calories'] ?? 0); // 각 음식의 칼로리를 합산함
        }
      }
    }
    return totalCalories.toInt(); // 총 칼로리를 정수로 반환함
  }

  // 오늘이 지나면 오늘 섭취한 칼로리를 계산하지 않도록 설정하는 함수
  bool _isToday(String date) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return date == today;
  }

  // 오늘 섭취한 영양정보를 계산하는 함수
  Map<String, num> _calculateTodayNutrition() {
    num carbs = 0;
    num protein = 0;
    num fat = 0;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    for (var diet in diets) {
      if (_isToday(diet['date'])) { // 오늘 날짜의 식단만 합산
        for (var food in diet['foods']) {
          carbs += (food['carbs'] ?? 0);
          protein += (food['protein'] ?? 0);
          fat += (food['fat'] ?? 0);
        }
      }
    }
    return {'carbs': carbs, 'protein': protein, 'fat': fat};
  }

  // 식단 옵션 메뉴를 표시하는 함수
  void _showDietOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.info, color: Colors.blue),
                title: Text('식단 상세 정보'),
                onTap: () {
                  Navigator.of(context).pop(); // 모달 닫기
                  _goToDietDetailPage(index); // 상세 페이지로 이동
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('식단 삭제'),
                onTap: () {
                  Navigator.of(context).pop(); // 모달 닫기
                  _showDeleteConfirmationDialog(index); // 삭제 확인 다이얼로그 표시
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 삭제 확인 다이얼로그 표시 함수
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          backgroundColor: Colors.white,
          content: Text('해당 식단을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소',
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.black
                  )
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: Text('삭제',
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.red
                  )
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _removeDiet(index); // 식단 삭제
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayNutrition = _calculateTodayNutrition();

    // 총 영양 성분 합산 값 계산
    num totalNutrition = (todayNutrition['carbs'] ?? 0) +
        (todayNutrition['protein'] ?? 0) +
        (todayNutrition['fat'] ?? 0);

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
          : ListView(
        padding: const EdgeInsets.symmetric(
            vertical: 16.0, horizontal: 12.0), // 전체 패딩 설정
        children: [
          Text(
            _isToday(DateFormat('yyyy-MM-dd').format(DateTime.now()))
                ? '오늘 섭취 칼로리: ${_calculateTotalCalories()} kcal' // 오늘 총 칼로리 표시
                : '오늘 섭취한 칼로리 정보가 없습니다.',
            style: TextStyle(
              fontFamily: 'Roboto', // 폰트 설정
              fontSize: 20.0, // 글자 크기 설정
              fontWeight: FontWeight.bold, // 글자 두께 설정
              color: Colors.black, // 글자 색상 설정
            ),
            textAlign: TextAlign.center, // 텍스트 가운데 정렬
          ),
          SizedBox(height: 16.0),
          // 영양정보 도넛형 그래프
          if (totalNutrition > 0)
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: (todayNutrition['carbs'] ?? 0).toDouble(),
                          title:
                          '${((todayNutrition['carbs'] ?? 0) / totalNutrition * 100).toStringAsFixed(1)}%',
                          color: Colors.blue,
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value:
                          (todayNutrition['protein'] ?? 0).toDouble(),
                          title:
                          '${((todayNutrition['protein'] ?? 0) / totalNutrition * 100).toStringAsFixed(1)}%',
                          color: Color(0xFF87CEEB),
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: (todayNutrition['fat'] ?? 0).toDouble(),
                          title:
                          '${((todayNutrition['fat'] ?? 0) / totalNutrition * 100).toStringAsFixed(1)}%',
                          color: Color(0xFFE6E6FA),
                          radius: 50,
                        ),
                      ],
                      sectionsSpace: 2, // 섹션 간 간격
                      centerSpaceRadius: 40, // 가운데 공간 크기
                    ),
                    swapAnimationDuration:
                    Duration(milliseconds: 800), // 애니메이션 시간 설정
                    swapAnimationCurve: Curves.easeInOut, // 애니메이션 곡선 설정
                  ),
                ),
                SizedBox(height: 16.0),
                // 영양정보 라벨
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegend(Colors.blue, '탄수화물'),
                    SizedBox(width: 16.0),
                    _buildLegend(Color(0xFF87CEEB), '단백질'),
                    SizedBox(width: 16.0),
                    _buildLegend(Color(0xFFE6E6FA), '지방'),
                  ],
                ),
              ],
            ),
          SizedBox(height: 16.0),
          ...diets.asMap().entries.map((entry) {
            final index = entry.key;
            final diet = entry.value;

            return GestureDetector(
              onTap: () {
                _goToDietDetailPage(index); // 식단을 탭하면 상세 페이지로 이동함
              },

              onLongPress: () {
                _showDietOptions(index); // 식단 옵션 메뉴 표시
              },

              child: Card(
                color: Colors.white, // 카드 배경색을 흰색으로 설정
                elevation: 4.0, // 카드 그림자 높이 설정
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0), // 카드 여백 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // 카드 모서리 둥글게 설정
                  side: BorderSide(
                    color: Colors.black, // 테두리 색상을 검정색으로 설정
                    width: 1.0, // 테두리 두께 설정
                  ),
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
                  subtitle: Text(
                    '${diet['date']}', // 식단 추가 날짜 표시
                    style: const TextStyle(
                      fontSize: 14.0, // 글자 크기 설정
                      fontFamily: 'Roboto', // 폰트 설정
                      color: Colors.black54, // 글자 색상 설정
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
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


  // 라벨을 표시하는 위젯 생성 함수
  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
          ),
        ),
        SizedBox(width: 4.0),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
