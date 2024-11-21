// 식단 추가 페이지
import 'package:flutter/material.dart'; // Flutter의 기본 위젯들을 제공하는 패키지
import 'package:flutter/services.dart'; // 애플리케이션의 자산(asset)에 접근하거나 시스템과의 상호작용을 위해 사용
import 'package:oss_team_project_app/utils/json_loader.dart'; // JSON 로더 임포트

// AddDietPage는 새로운 식단을 추가할 수 있는 화면을 제공한다
class AddDietPage extends StatefulWidget {
  @override
  _AddDietPageState createState() => _AddDietPageState();
}

class _AddDietPageState extends State<AddDietPage> {
  // 식단 이름을 입력받기 위한 텍스트 컨트롤러
  final TextEditingController dietNameController = TextEditingController();

  // 음식 이름을 입력받기 위한 텍스트 컨트롤러
  final TextEditingController foodNameController = TextEditingController();

  // 음식 칼로리를 입력받기 위한 텍스트 컨트롤러
  final TextEditingController foodCalorieController = TextEditingController();

  // 선택 가능한 식사 종류 리스트
  final List<String> mealTypes = ['아침', '점심', '저녁', '간식']; //임시로 아침,점심,저녁,간식을 적어 넣음, 추후 다른 방식으로 활용할 수 있음

  // 현재 선택된 식사 종류를 저장하는 변수
  String? selectedMealType;

  // 추가된 음식 목록을 저장하는 리스트
  List<Map<String, dynamic>> foodList = [];

  // 추가한 변수: JSON 데이터를 저장하는 리스트
  List<Map<String, dynamic>> foodData = [];

  @override
  void initState() {
    super.initState();
    _loadFoodData(); // JSON 데이터를 로드
  }

  // 추가한 함수: JSON 데이터를 로드하는 함수
  Future<void> _loadFoodData() async {
    foodData = await loadJsonData(); // json_loader.dart의 loadJsonData 함수 호출
  }

  // JSON 데이터를 이용하여 음식을 검색 후 추가
  void _searchAndAddFood() async {
    if (foodData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('음식 데이터를 불러오는 중입니다. 잠시 후 다시 시도해주세요.')),
      );
      return;
    }

    showSearch(
      context: context,
      delegate: FoodSearchDelegate(
        foodData: foodData, // 검색에 사용할 JSON 데이터
        onFoodSelected: (selectedFood) {
          setState(() {
            // 선택된 음식을 foodList에 추가
            foodList.add({
              'foodName': selectedFood['음식명'], // JSON 데이터의 '음식명' 키 사용
              'calories': selectedFood['칼로리'], // JSON 데이터의 '칼로리' 키 사용
            });
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    // 페이지가 사라질 때 텍스트 컨트롤러를 해제하여 메모리 누수를 방지
    dietNameController.dispose();
    foodNameController.dispose();
    foodCalorieController.dispose();
    super.dispose();
  }

  // 새로운 음식을 foodList에 추가하는 함수
  void _addFood() {
    // 음식 이름과 칼로리가 비어있지 않고, 칼로리가 정수인지 확인
    if (foodNameController.text.isNotEmpty &&
        foodCalorieController.text.isNotEmpty &&
        int.tryParse(foodCalorieController.text) != null) {

      // 새로운 음식 항목 생성
      final newFood = {
        'foodName': foodNameController.text, // 음식 이름
        'calories': int.parse(foodCalorieController.text), // 음식 칼로리
      };

      setState(() {
        foodList.add(newFood); // 음식 목록에 새 음식 추가
      });

      // 입력 필드 초기화
      foodNameController.clear();
      foodCalorieController.clear();
    } else {
      // 입력이 유효하지 않을 경우 스낵바로 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('음식 이름과 칼로리를 올바르게 입력해주세요.')),
      );
    }
  }

  // 새로 추가된 식단을 저장하고 이전 화면으로 돌아가는 함수
  void _saveDiet() {
    // 음식 목록이 비어있지 않은지 확인
    if (foodList.isNotEmpty) {
      // 새로운 식단 데이터 생성
      final newDiet = {
        'name': dietNameController.text, // 식단 이름
        'mealType': selectedMealType, // 선택된 식사 종류
        'foods': List<Map<String, dynamic>>.from(foodList), // 음식 목록
      };

      // 이전 화면으로 새 식단 데이터를 전달하며 돌아감
      Navigator.pop(context, newDiet);
    } else {
      // 음식 목록이 비어있을 경우 스낵바로 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최소 한 개의 음식을 추가해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 앱바의 배경색을 흰색으로 설정
        iconTheme: IconThemeData(color: Colors.black), // 앱바 아이콘의 색상을 검은색으로 설정
        title: Text(
          '식단 추가', // 앱바의 제목 텍스트
          style: TextStyle(
            fontFamily: 'Bebas Neue', // 폰트 설정
            fontSize: 28.0, // 폰트 크기 설정
            fontWeight: FontWeight.w900, // 폰트 두께 설정
            color: Colors.black, // 텍스트 색상 설정
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // 전체 패딩을 16.0으로 설정
        child: ListView(
          children: [
            // 식단 이름 입력 필드 레이블
            _buildTextField(
              controller: dietNameController, // 식단 이름 텍스트 필드 컨트롤러 연결
              label: '식단 이름', // 텍스트 필드의 라벨
              hintText: '식단 이름을 입력하세요', // 텍스트 필드의 힌트 텍스트
            ),
            SizedBox(height: 16.0), // 간격 추가

            // 식사 종류 선택 드롭다운 필드
            DropdownButtonFormField<String>(
              value: selectedMealType, // 현재 선택된 식사 종류
              items: mealTypes.map((mealType) => DropdownMenuItem(
                value: mealType, // 드롭다운 항목의 값 설정
                child: Text(
                  mealType, // 드롭다운 항목의 텍스트
                  style: TextStyle(
                    fontFamily: 'Roboto', // 폰트 설정
                    fontWeight: FontWeight.w600, // 글자 두께 설정
                    fontSize: 16.0, // 글자 크기 설정
                  ),
                ),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMealType = value; // 선택된 식사 종류 업데이트
                });
              },
              decoration: InputDecoration(
                labelText: '식사 종류', // 드롭다운 필드의 라벨 텍스트
                labelStyle: TextStyle(
                  fontFamily: 'Roboto', // 폰트 설정
                  fontWeight: FontWeight.w600, // 글자 두께 설정
                  fontSize: 16.0, // 글자 크기 설정
                ),
                border: InputBorder.none, // 드롭다운 필드의 테두리를 없음으로 설정
              ),
            ),
            SizedBox(height: 16.0), // 간격 추가

            // 음식 이름 입력 필드 레이블
            _buildTextField(
              controller: foodNameController, // 음식 이름 텍스트 필드 컨트롤러 연결
              label: '음식 이름', // 텍스트 필드의 라벨
              hintText: '음식 이름을 입력하세요', // 텍스트 필드의 힌트 텍스트
            ),
            SizedBox(height: 16.0), // 간격 추가

            // 음식 칼로리 입력 필드 레이블
            _buildTextField(
              controller: foodCalorieController, // 음식 칼로리 텍스트 필드 컨트롤러 연결
              label: '칼로리 (kcal)', // 텍스트 필드의 라벨
              hintText: '음식의 칼로리를 입력하세요', // 텍스트 필드의 힌트 텍스트
              keyboardType: TextInputType.number, // 숫자 키보드 사용 설정
            ),
            SizedBox(height: 16.0), // 간격 추가

            // 음식 추가 버튼
            // 기존 음식 추가 버튼
            ElevatedButton(
              onPressed: _addFood, // 버튼 클릭 시 _addFood 함수 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                '음식 추가',
                style: TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16.0), // 간격 추가

            // 추가할 음식 검색 버튼
            ElevatedButton(
              onPressed: _searchAndAddFood, // JSON 데이터 기반 검색
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                '음식 검색',
                style: TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: 16.0), // 간격 추가

            // 음식 목록이 비어있지 않을 경우 추가된 음식 목록을 표시
            if (foodList.isNotEmpty) ...[
              // 추가된 음식 목록 제목
              Text(
                '추가된 음식 목록',
                style: TextStyle(
                  fontFamily: 'Roboto', // 폰트 설정
                  fontWeight: FontWeight.w600, // 글자 두께 설정
                  fontSize: 18.0, // 글자 크기 설정
                  color: Colors.black, // 글자 색상 설정
                ),
              ),
              SizedBox(height: 8.0), // 간격 추가

              // 추가된 각 음식을 ListTile 형태로 표시
              ...foodList.asMap().entries.map((entry) {
                int index = entry.key; // 음식의 인덱스
                Map<String, dynamic> food = entry.value; // 음식 데이터

                return ListTile(
                  title: Text(
                    '${food['foodName']} - ${food['calories']}kcal', // 음식 이름과 칼로리 표시
                    style: TextStyle(
                      fontFamily: 'Roboto', // 폰트 설정
                      fontSize: 16.0, // 글자 크기 설정
                      color: Colors.black87, // 글자 색상 설정
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete), // 삭제 아이콘 설정
                    onPressed: () {
                      setState(() {
                        foodList.removeAt(index); // 해당 음식을 목록에서 제거
                      });
                    },
                  ),
                );
              }).toList(),
            ],
            SizedBox(height: 32.0), // 간격 추가

            // 식단 저장 버튼
            ElevatedButton(
              onPressed: _saveDiet, // 버튼 클릭 시 _saveDiet 함수 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼 배경색을 파란색으로 설정
                elevation: 4.0, // 버튼의 그림자 높이를 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // 버튼 모서리를 둥글게 설정
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼의 세로 패딩을 16.0으로 설정
              ),
              child: Text(
                '저장', // 버튼에 표시될 텍스트
                style: TextStyle(
                  fontFamily: 'Bebas Neue', // 폰트 설정
                  fontSize: 20.0, // 폰트 크기 설정
                  fontWeight: FontWeight.bold, // 폰트 두께 설정
                  color: Colors.white, // 텍스트 색상을 흰색으로 설정
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 일관된 스타일의 텍스트 필드를 생성하는 헬퍼 메소드
  Widget _buildTextField({
    required TextEditingController controller, // 입력을 제어하는 컨트롤러
    required String label, // 텍스트 필드의 라벨
    String? hintText, // 텍스트 필드의 힌트 텍스트
    TextInputType keyboardType = TextInputType.text, // 키보드 타입 설정 (기본값: 텍스트)
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0), // 컨테이너의 가로 패딩을 12.0으로 설정
      decoration: BoxDecoration(
        color: Colors.grey[100], // 컨테이너의 배경색을 연한 회색으로 설정
        borderRadius: BorderRadius.circular(16.0), // 컨테이너의 모서리를 둥글게 설정
      ),
      child: TextField(
        controller: controller, // 텍스트 필드에 컨트롤러 연결
        decoration: InputDecoration(
          labelText: label, // 텍스트 필드의 라벨 텍스트 설정
          labelStyle: TextStyle(
            fontFamily: 'Roboto', // 폰트 설정
            fontWeight: FontWeight.w600, // 글자 두께 설정
            fontSize: 16.0, // 글자 크기 설정
          ),
          hintText: hintText, // 텍스트 필드의 힌트 텍스트 설정
          border: InputBorder.none, // 텍스트 필드의 테두리를 없음으로 설정
        ),
        keyboardType: keyboardType, // 텍스트 필드의 키보드 타입 설정
      ),
    );
  }
}

class FoodSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> foodData;
  final Function(Map<String, dynamic>) onFoodSelected;

  FoodSearchDelegate({required this.foodData, required this.onFoodSelected});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = foodData.where((food) {
      final foodName = food['음식명'] as String;
      return foodName.contains(query);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final food = results[index];
        return ListTile(
          title: Text('${food['음식명']}'),
          subtitle: Text('칼로리: ${food['칼로리']} kcal'),
          onTap: () {
            onFoodSelected(food);
            close(context, null);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
