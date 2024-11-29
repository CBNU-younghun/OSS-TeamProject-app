import 'package:flutter/material.dart'; // Flutter의 기본 위젯들을 제공하는 패키지
import 'package:fl_chart/fl_chart.dart'; // 차트 표현을 위해 사용
import 'package:flutter/services.dart'; // JSON 파일을 로드하기 위해 사용
import 'dart:convert'; // JSON 데이터를 디코딩하기 위해 사용

// DietDetailPage는 사용자가 선택한 식단의 상세 정보를 보고 수정 또는 삭제할 수 있는 페이지이다
class DietDetailPage extends StatefulWidget {
  final Map<String, dynamic> diet; // 상세 정보를 표시할 식단 데이터
  final Function(Map<String, dynamic>) onSave; // 식단 저장 시 호출될 콜백 함수
  final Function() onDelete; // 식단 삭제 시 호출될 콜백 함수

  // 생성자에서 필수로 식단 데이터, 저장 및 삭제 콜백 함수를 받는다
  DietDetailPage({
    required this.diet,
    required this.onSave,
    required this.onDelete,
  });

  @override
  _DietDetailPageState createState() => _DietDetailPageState();
}

class _DietDetailPageState extends State<DietDetailPage> {
  final TextEditingController nameController = TextEditingController(); // 식단 이름을 제어하는 텍스트 컨트롤러
  List<Map<String, dynamic>> foods = []; // 식단에 포함된 음식 목록을 저장하는 리스트

  @override
  void initState() {
    super.initState();
    _loadDietData(); // 위젯 초기화 시 식단 데이터를 로드함
  }

  // 초기 식단 데이터를 로드하여 상태를 설정하는 함수
  void _loadDietData() {
    nameController.text = widget.diet['name']; // 식단 이름을 텍스트 필드에 설정함
    foods = List<Map<String, dynamic>>.from(widget.diet['foods']); // 음식 목록을 설정함
  }

  // 식단을 저장하는 함수
  void _saveDiet() {
    if (nameController.text.isNotEmpty) { // 식단 이름이 입력되었는지 확인
      final updatedDiet = {
        'name': nameController.text, // 입력된 식단 이름
        'foods': foods, // 현재 음식 목록
      };
      widget.onSave(updatedDiet); // 상위 위젯의 onSave 콜백 함수 호출
      Navigator.pop(context); // 상세 페이지를 닫음
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('올바른 정보를 입력해주세요.')), // 유효하지 않은 입력 시 스낵바 표시
      );
    }
  }

  // 식단을 삭제하는 함수
  void _deleteDiet() {
    widget.onDelete(); // 상위 위젯의 onDelete 콜백 함수 호출
    Navigator.pop(context); // 상세 페이지를 닫음
  }

  // 음식 항목에 대한 편집 옵션을 보여주는 함수
  void _showEditOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0), // 컨테이너 패딩 설정
          child: Column(
            mainAxisSize: MainAxisSize.min, // 컨텐츠에 맞게 크기 조절
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue), // 수정 아이콘
                title: Text('음식 수정'), // 수정 옵션 텍스트
                onTap: () {
                  Navigator.pop(context); // 모달 닫기
                  _showEditFoodForm(index); // 음식 수정 폼 표시
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red), // 삭제 아이콘
                title: Text('음식 삭제'), // 삭제 옵션 텍스트
                onTap: () {
                  Navigator.pop(context); // 모달 닫기
                  setState(() {
                    foods.removeAt(index); // 지정된 인덱스의 음식을 목록에서 제거
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 음식 항목을 수정할 수 있는 폼을 보여주는 함수
  void _showEditFoodForm(int index) {
    final TextEditingController foodNameController = TextEditingController(text: foods[index]['foodName']); // 음식 이름을 제어하는 텍스트 컨트롤러
    final TextEditingController foodCalorieController = TextEditingController(text: foods[index]['calories'].toString()); // 음식 칼로리를 제어하는 텍스트 컨트롤러

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드가 올라올 때 스크롤 가능하게 설정
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // 키보드 높이에 따라 패딩 조절
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 내부 패딩 설정
            child: Column(
              mainAxisSize: MainAxisSize.min, // 컨텐츠에 맞게 크기 조절
              children: [
                _buildTextField(
                  controller: foodNameController,
                  label: '음식 이름',
                  hintText: '음식 이름을 입력하세요',
                ),
                SizedBox(height: 16.0), // 텍스트 필드 간격 추가
                _buildTextField(
                  controller: foodCalorieController,
                  label: '칼로리 (kcal)',
                  hintText: '음식의 칼로리를 입력하세요',
                  keyboardType: TextInputType.number, // 숫자 키보드 사용
                ),
                SizedBox(height: 32.0), // 버튼 간격 추가
                ElevatedButton(
                  onPressed: () {
                    if (foodNameController.text.isNotEmpty && int.tryParse(foodCalorieController.text) != null) { // 입력 유효성 검사
                      setState(() {
                        foods[index] = {
                          'foodName': foodNameController.text, // 수정된 음식 이름
                          'calories': int.parse(foodCalorieController.text), // 수정된 음식 칼로리
                        };
                      });
                      Navigator.pop(context); // 모달 닫기
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('올바른 정보를 입력해주세요.')), // 유효하지 않은 입력 시 스낵바 표시
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // 버튼 배경색 설정
                    elevation: 4.0, // 버튼 그림자 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0), // 버튼 모서리 둥글게 설정
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 패딩 설정
                  ),
                  child: Text(
                    '저장', // 버튼 텍스트
                    style: TextStyle(
                      fontFamily: 'Bebas Neue', // 폰트 설정
                      fontSize: 20.0, // 폰트 크기 설정
                      fontWeight: FontWeight.bold, // 폰트 두께 설정
                      color: Colors.white, // 텍스트 색상 설정
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose(); // 텍스트 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 앱바 배경색을 흰색으로 설정
        title: Text(
          '식단 상세', // 앱바 제목 설정
          style: TextStyle(
            fontFamily: 'Bebas Neue', // 폰트 적용
            fontSize: 28.0, // 폰트 크기 설정
            fontWeight: FontWeight.w900, // 폰트 두께 설정
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black), // 앱바 아이콘 색상을 검은색으로 설정
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // 전체 패딩 설정
        child: ListView(
          children: [
            Text(
              '식단 이름:', // 식단 이름 레이블
              style: TextStyle(
                fontFamily: 'Roboto', // 폰트 설정
                fontSize: 18.0, // 글자 크기 설정
                fontWeight: FontWeight.bold, // 글자 두께 설정
              ),
            ),
            _buildTextField(
              controller: nameController, // 식단 이름 텍스트 필드 컨트롤러 연결
              label: '식단 이름', // 텍스트 필드 라벨
              hintText: '식단 이름을 입력하세요', // 텍스트 필드 힌트
            ),
            SizedBox(height: 16.0), // 간격 추가
            if (foods.isNotEmpty) ...[
              SizedBox(
                height: 400, // 차트 높이 증가
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround, // 막대 간 간격을 일정하게 설정
                    barGroups: [
                      _makeVerticalBarGroup(0, '탄수화물', _getTotalNutrient('carbs'), Colors.greenAccent),
                      _makeVerticalBarGroup(1, '단백질', _getTotalNutrient('protein'), Colors.orangeAccent),
                      _makeVerticalBarGroup(2, '지방', _getTotalNutrient('fat'), Colors.redAccent),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (value, _) {
                            switch (value.toInt()) {
                              case 0:
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('탄수화물', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                );
                              case 1:
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('단백질', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                );
                              case 2:
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('지방', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                );
                              default:
                                return Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, _) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 12, color: Colors.black),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey, width: 1), // 테두리 추가
                    ),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300]!, // 그리드 선 색상 설정
                          strokeWidth: 1,
                        );
                      },
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String nutrient;
                          switch (group.x.toInt()) {
                            case 0:
                              nutrient = '탄수화물';
                              break;
                            case 1:
                              nutrient = '단백질';
                              break;
                            case 2:
                              nutrient = '지방';
                              break;
                            default:
                              nutrient = '';
                              break;
                          }
                          return BarTooltipItem(
                            '$nutrient: ${rod.toY.round()}g',
                            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    maxY: 100,
                  ),
                ),
              ),
              SizedBox(height: 32.0),
              Text(
                '추가된 음식 목록:', // 음식 목록 제목
                style: TextStyle(
                  fontFamily: 'Roboto', // 폰트 설정
                  fontWeight: FontWeight.bold, // 글자 두께 설정
                  fontSize: 18.0, // 글자 크기 설정
                  color: Colors.black, // 글자 색상 설정
                ),
              ),
              SizedBox(height: 8.0), // 간격 추가
              // add_diet에서 추가된 음식 목록만 리스트 형태로 표시
              ...foods.asMap().entries.map((entry) {
                int index = entry.key; // 음식의 인덱스
                Map<String, dynamic> food = entry.value; // 음식 데이터
                if (widget.diet['foods'].contains(food)) { // 현재 식단에 추가된 음식만 표시
                  return ListTile(
                    title: Text(
                      '${food['foodName']} - ${food['calories']} kcal', // 음식 이름과 칼로리 표시
                      style: TextStyle(
                        fontFamily: 'Roboto', // 폰트 설정
                        fontSize: 16.0, // 글자 크기 설정
                        color: Colors.black87, // 글자 색상 설정
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.black), // 옵션 아이콘 설정
                      onPressed: () => _showEditOptions(index), // 옵션 버튼 클릭 시 편집 옵션 표시
                    ),
                  );
                } else {
                  return SizedBox.shrink(); // 다른 음식은 표시하지 않음
                }
              }).toList(),
            ],
            SizedBox(height: 32.0), // 간격 추가
            ElevatedButton(
              onPressed: _saveDiet, // 저장 버튼 클릭 시 식단 저장 함수 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼 배경색 설정
                elevation: 4.0, // 버튼 그림자 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // 버튼 모서리 둥글게 설정
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 패딩 설정
              ),
              child: Text(
                '저장', // 버튼 텍스트
                style: TextStyle(
                  fontFamily: 'Bebas Neue', // 폰트 설정
                  fontSize: 20.0, // 폰트 크기 설정
                  fontWeight: FontWeight.bold, // 폰트 두께 설정
                  color: Colors.white, // 텍스트 색상 설정
                ),
              ),
            ),
            SizedBox(height: 16.0), // 간격 추가
            ElevatedButton(
              onPressed: _deleteDiet, // 삭제 버튼 클릭 시 식단 삭제 함수 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // 버튼 배경색 설정
                elevation: 4.0, // 버튼 그림자 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // 버튼 모서리 둥글게 설정
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 패딩 설정
              ),
              child: Text(
                '삭제', // 버튼 텍스트
                style: TextStyle(
                  fontFamily: 'Bebas Neue', // 폰트 설정
                  fontSize: 20.0, // 폰트 크기 설정
                  fontWeight: FontWeight.bold, // 폰트 두께 설정
                  color: Colors.white, // 텍스트 색상 설정
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 주어진 영양소의 총합을 계산하는 함수
  double _getTotalNutrient(String nutrient) {
    double total = 0;
    for (var food in foods) {
      total += (food[nutrient] ?? 0).toDouble(); // null 체크 후 toDouble() 호출
    }
    return total;
  }

  // 세로 막대 그룹을 생성하는 함수
  BarChartGroupData _makeVerticalBarGroup(int x, String label, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 20,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: Colors.grey[200],
          ),
        ),
      ],
      barsSpace: 16,
    );
  }

  // 일관된 스타일의 텍스트 필드를 생성하는 헬퍼 메소드
  Widget _buildTextField({
    required TextEditingController controller, // 입력을 제어하는 컨트롤러
    required String label, // 라벨 텍스트
    String? hintText, // 힌트 텍스트
    TextInputType keyboardType = TextInputType.text, // 키보드 타입 설정 (기본값: 텍스트)
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0), // 컨테이너 패딩 설정
      decoration: BoxDecoration(
        color: Colors.grey[100], // 배경색 설정
        borderRadius: BorderRadius.circular(16.0), // 모서리 둥글게 설정
      ),
      child: TextField(
        controller: controller, // 텍스트 컨트롤러 연결
        decoration: InputDecoration(
          labelText: label, // 라벨 텍스트 설정
          labelStyle: TextStyle(
            fontFamily: 'Roboto', // 폰트 설정
            fontWeight: FontWeight.w600, // 글자 두께 설정
            fontSize: 16.0, // 글자 크기 설정
          ),
          hintText: hintText, // 힌트 텍스트 설정
          border: InputBorder.none, // 테두리 없음
        ),
        keyboardType: keyboardType, // 키보드 타입 설정
      ),
    );
  }
}
