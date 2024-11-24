import 'package:flutter/material.dart'; // Flutter의 기본 위젯들을 제공하는 패키지
import 'package:flutter/services.dart'; // 애플리케이션의 자산(asset)에 접근하기 위해 사용
import 'dart:convert'; // JSON 데이터를 파싱하기 위해 사용

// 식단 추가 페이지를 위한 StatefulWidget 정의
class AddDietPage extends StatefulWidget {
  @override
  _AddDietPageState createState() => _AddDietPageState();
}

// 식단 추가 페이지의 상태 관리 클래스
class _AddDietPageState extends State<AddDietPage> {
  // 입력된 식단 이름을 관리하는 컨트롤러
  final TextEditingController dietNameController = TextEditingController();

  // 선택된 음식 목록을 저장하는 리스트
  List<Map<String, dynamic>> foodList = [];

  // 특정 카테고리의 음식 데이터를 저장하는 리스트
  List<Map<String, dynamic>> foodData = [];

  // 선택된 카테고리와 음식
  String? selectedCategory;
  String? selectedFood;

  // 음식 카테고리 리스트
  List<String> categories = [
    '곡류,서류 제품', '과일류', '구이류', '국 및 탕류', '김치류', '나물·숙채류', '두류, 견과 및 종실류', '면 및 만두류', '밥류', '볶음류',
    '빵 및 과자류', '생채·무침류', '수·조·어·육류', '유제품류 및 빙과류', '음료 및 차류', '장류, 양념류',
    '장아찌·절임류', '전·적 및 부침류', '젓갈류', '조림류', '죽 및 스프류', '찌개 및 전골류', '찜류', '튀김류'
  ];

  // 선택된 카테고리에 따라 필터링된 음식 이름 리스트
  List<String> filteredFoods = [];

  // 선택된 카테고리에 해당하는 JSON 데이터를 로드
  Future<void> _loadFoodDataByCategory(String category) async {
    try {
      // JSON 파일 경로 설정
      String fileName = 'assets/food_data_by_category/${category}.json';

      // JSON 파일 읽기
      String jsonString = await rootBundle.loadString(fileName);

      // JSON 문자열을 파싱하여 리스트로 변환
      List<dynamic> jsonResponse = json.decode(jsonString);

      // 불필요한 "records/" 접두어 제거 후 정리
      List<Map<String, dynamic>> cleanedData = jsonResponse.map((item) {
        return {
          '식품명': item['records/식품명'],
          '에너지(kcal)': item['records/에너지(kcal)'],
          '탄수화물(g)': item['records/탄수화물(g)'],
          '단백질(g)': item['records/단백질(g)'],
          '지방(g)': item['records/지방(g)'],
        };
      }).toList();

      // 상태 업데이트
      setState(() {
        foodData = cleanedData;
        filteredFoods = foodData.map((food) => food['식품명'] as String).toSet().toList(); // 중복 제거
        selectedFood = null; // 새 카테고리 선택 시 선택된 음식 초기화
      });
    } catch (e) {
      // 오류 발생 시 스낵바로 알림 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('음식 데이터를 불러오는 중 오류가 발생했습니다: ${e.toString()}')),
      );
    }
  }

  // 새로운 음식을 추가하는 함수
  void _addFood() {
    if (selectedFood == null) {
      // 음식이 선택되지 않았을 경우 경고 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('음식을 선택해주세요.')),
      );
      return;
    }

    // 선택된 음식 데이터를 foodData 리스트에서 가져오기
    final selectedFoodData = foodData.firstWhere(
          (food) => food['식품명'] == selectedFood,
    );

    // 선택된 음식 데이터를 foodList에 추가
    setState(() {
      foodList.add({
        'foodName': selectedFoodData['식품명'],
        'calories': selectedFoodData['에너지(kcal)'],
        'carbs': selectedFoodData['탄수화물(g)'],
        'protein': selectedFoodData['단백질(g)'],
        'fat': selectedFoodData['지방(g)'],
      });
    });

    // 선택 항목 초기화
    selectedCategory = null;
    filteredFoods = [];
    selectedFood = null;
  }

  // 식단을 저장하는 함수
  void _saveDiet() {
    if (foodList.isNotEmpty) {
      // 새로운 식단 데이터를 생성하여 Navigator를 통해 이전 화면으로 전달
      final newDiet = {
        'name': dietNameController.text,
        'foods': List<Map<String, dynamic>>.from(foodList),
      };
      Navigator.pop(context, newDiet);
    } else {
      // 음식이 추가되지 않은 경우 경고 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최소 한 개의 음식을 추가해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 앱바 배경색
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상
        title: Text(
          '식단 추가', // 앱바 제목
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 28.0,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // 페이지 전체 패딩 설정
        child: ListView(
          children: [
            // 식단 이름 입력 필드
            _buildTextField(
              controller: dietNameController,
              label: '식단 이름',
              hintText: '식단 이름을 입력하세요',
            ),
            SizedBox(height: 16.0),

// 카테고리 선택 드롭다운
            Container(
              width: double.infinity, // 화면의 너비에 맞게 설정
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value; // 선택된 카테고리 업데이트
                    if (value != null) {
                      _loadFoodDataByCategory(value); // 선택된 카테고리에 해당하는 음식 데이터 로드
                    }
                  });
                },
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                hint: Text('카테고리 선택'), // 선택되지 않았을 때 표시될 기본 텍스트 추가
                decoration: InputDecoration(
                  labelText: '카테고리 선택', // 드롭다운 라벨
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16.0),

// 음식 선택 드롭다운 (카테고리 선택 후 표시)
            if (filteredFoods.isNotEmpty)
              Container(
                width: double.infinity, // 화면의 너비에 맞게 설정
                child: DropdownButtonFormField<String>(
                  value: selectedFood,
                  onChanged: (value) => setState(() => selectedFood = value),
                  items: filteredFoods.map((food) {
                    return DropdownMenuItem(
                      value: food,
                      child: Text(
                        food,
                        overflow: TextOverflow.ellipsis, // 너무 긴 텍스트는 '...'으로 표시
                      ),
                    );
                  }).toList(),
                  hint: Text('음식 선택'), // 선택되지 않았을 때 표시될 기본 텍스트 추가
                  decoration: InputDecoration(
                    labelText: '음식 선택',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true, // Dropdown이 화면 너비에 맞춰 확장되도록 설정
                ),
              ),
            SizedBox(height: 16.0),

            // 음식 추가 및 저장 버튼을 같은 줄에 배치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 음식 추가 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addFood,
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
                ),
                SizedBox(width: 16.0),
                // 저장 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveDiet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: Text(
                      '저장',
                      style: TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.0),

            // 추가된 음식 목록
            if (foodList.isNotEmpty) ...[
              Text(
                '추가된 음식 목록',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.0),
              // 각 음식 항목을 리스트로 표시
              ...foodList.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> food = entry.value;
                return ListTile(
                  title: Text(
                    '${food['foodName']} - ${food['calories']}kcal',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        foodList.removeAt(index); // 선택된 음식 삭제
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  // 텍스트 입력 필드를 생성하는 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}
