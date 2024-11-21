// 루틴 추가 페이지
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// AddRoutinePage는 새로운 운동 루틴을 추가할 수 있는 화면이다
class AddRoutinePage extends StatefulWidget {
  @override
  _AddRoutinePageState createState() => _AddRoutinePageState();
}

class _AddRoutinePageState extends State<AddRoutinePage> {
  final TextEditingController routineNameController = TextEditingController(); // 루틴 이름을 입력하는 컨트롤러
  List exercises = []; // 전체 운동 목록
  Map<String, dynamic>? selectedExercise; // 선택된 운동
  List<Map<String, dynamic>> addedExercises = []; // 추가된 운동 목록
  int? selectedTime; // 선택된 운동 시간
  int? selectedSets; // 선택된 세트 수
  List<int> secondsOptions = List.generate(60, (index) => index + 1); // 운동 시간 옵션 (1초부터 60초까지)
  List<int> setOptions = List.generate(10, (index) => index + 1); // 세트 수 옵션 (1세트부터 10세트까지)
  int? selectedReps; // 세트당 운동횟수
  List<int> repsOptions = List.generate(50, (index) => index + 1); // 세트당 운동횟수 옵션



  @override
  void initState() {
    super.initState();
    _loadExercises(); // 페이지 초기화 시 운동 데이터 로드
  }

  // 로컬 JSON 파일에서 운동 데이터를 로드한다
  Future<void> _loadExercises() async {
    String data = await rootBundle.loadString('assets/exercise_data.json'); // JSON 파일 로드
    setState(() {
      exercises = json.decode(data); // 운동 데이터 파싱
      if (exercises.isNotEmpty) {
        selectedExercise = exercises.first; // 기본으로 첫 번째 운동 선택
      }
    });
  }

  // 운동을 추가하는 함수이다
  void _addExercise() {
    if (selectedExercise != null && selectedTime != null && selectedSets != null) { // 유효성 검사
      setState(() {
        addedExercises.add({
          'exercise': selectedExercise!['name'], // 운동 이름 추가
          'time': selectedTime, // 운동 시간 추가
          'sets': selectedSets, // 세트 수 추가
          'bodyPart': selectedExercise!['bodyPart'], // 운동 부위 추가
          'reps':selectedReps, //세트 당 운동횟수 추가
        });
        selectedTime = null; // 선택된 시간 초기화
        selectedSets = null; // 선택된 세트 수 초기화
        selectedReps = null; // 선택된 세트 당 운동횟수 초기화
      });
    } else {
      // 유효하지 않은 입력 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('운동 정보와 시간을 올바르게 입력해주세요.')), // 오류 메시지 표시
      );
    }
  }

  // 추가된 운동을 제거하는 함수이다
  void _removeExercise(int index) {
    setState(() {
      addedExercises.removeAt(index); // 지정된 인덱스의 운동 제거
    });
  }

  // 루틴을 추가하는 함수이다
  void _addRoutine() {
    if (routineNameController.text.isNotEmpty && addedExercises.isNotEmpty) { // 유효성 검사
      final newRoutine = {
        'name': routineNameController.text, // 루틴 이름 설정
        'exercises': addedExercises, // 추가된 운동 목록 설정
      };
      Navigator.pop(context, newRoutine); // 새 루틴을 이전 화면으로 전달하며 닫기
    } else {
      // 유효하지 않은 입력 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('루틴 이름과 최소 하나의 운동을 추가해주세요.')), // 오류 메시지 표시
      );
    }
  }

  @override
  void dispose() {
    routineNameController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 앱바 배경색 설정
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 설정
        title: Text(
          '루틴 추가', // 앱바 제목
          style: TextStyle(
            fontFamily: 'Bebas Neue', // 폰트 설정
            fontSize: 28.0, // 글자 크기 설정
            fontWeight: FontWeight.w900, // 글자 두께 설정
            color: Colors.black, // 글자 색상 설정
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // 전체 패딩 설정
        child: exercises.isEmpty
            ? Center(child: CircularProgressIndicator()) // 운동 데이터 로딩 중일 때 표시
            : ListView(
          children: [
            _buildTextField(
              controller: routineNameController, // 루틴 이름 입력 필드
              label: '루틴 이름', // 라벨 텍스트 설정
            ),
            SizedBox(height: 16.0), // 간격 추가

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0), // 컨테이너 패딩 설정
              decoration: BoxDecoration(
                color: Colors.grey[100], // 배경색 설정
                borderRadius: BorderRadius.circular(16.0), // 모서리 둥글게 설정
              ),
              child: DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedExercise, // 현재 선택된 운동
                items: exercises.map<DropdownMenuItem<Map<String, dynamic>>>((exercise) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: exercise, // 각 운동을 드롭다운 항목으로 설정
                    child: Text(
                      exercise['name'], // 운동 이름 표시
                      style: TextStyle(
                        fontFamily: 'Roboto', // 폰트 설정
                        fontWeight: FontWeight.w600, // 글자 두께 설정
                        fontSize: 16.0, // 글자 크기 설정
                        color: Colors.black87, // 글자 색상 설정
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedExercise = value; // 선택된 운동 업데이트
                  });
                },
                decoration: InputDecoration(
                  labelText: '운동 종류', // 라벨 텍스트 설정
                  labelStyle: TextStyle(
                    fontFamily: 'Roboto', // 폰트 설정
                    fontWeight: FontWeight.w600, // 글자 두께 설정
                    fontSize: 16.0, // 글자 크기 설정
                    color: Colors.black87, // 글자 색상 설정
                  ),
                  border: InputBorder.none, // 테두리 없음
                ),
              ),
            ),
            SizedBox(height: 8.0), // 간격 추가
            if (selectedExercise != null) ...[
              Text(
                '운동 부위: ${selectedExercise!['bodyPart']}', // 선택된 운동의 부위 표시
                style: TextStyle(
                  fontFamily: 'Roboto', // 폰트 설정
                  fontSize: 16.0, // 글자 크기 설정
                  color: Colors.black, // 글자 색상 설정
                ),
              ),
            ],
            SizedBox(height: 16.0), // 간격 추가
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0), // 컨테이너 패딩 설정
              decoration: BoxDecoration(
                color: Colors.grey[100], // 배경색 설정
                borderRadius: BorderRadius.circular(16.0), // 모서리 둥글게 설정
              ),
              child: DropdownButtonFormField<int>(
                value: selectedTime, // 현재 선택된 시간
                items: secondsOptions.map((seconds) => DropdownMenuItem(
                  value: seconds, // 각 시간 값을 드롭다운 항목으로 설정
                  child: Text(
                    '$seconds 초', // 시간 표시
                    style: TextStyle(
                      fontFamily: 'Roboto', // 폰트 설정
                      fontWeight: FontWeight.w600, // 글자 두께 설정
                      fontSize: 16.0, // 글자 크기 설정
                      color: Colors.black87, // 글자 색상 설정
                    ),
                  ),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTime = value; // 선택된 시간 업데이트
                  });
                },
                decoration: InputDecoration(
                  labelText: '운동 시간 (초)', // 라벨 텍스트 설정
                  labelStyle: TextStyle(
                    fontFamily: 'Roboto', // 폰트 설정
                    fontWeight: FontWeight.w600, // 글자 두께 설정
                    fontSize: 16.0, // 글자 크기 설정
                    color: Colors.black87, // 글자 색상 설정
                  ),
                  border: InputBorder.none, // 테두리 없음
                ),
              ),
            ),
            SizedBox(height: 16.0), // 간격 추가

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0), // 컨테이너 패딩 설정
              decoration: BoxDecoration(
                color: Colors.grey[100], // 배경색 설정
                borderRadius: BorderRadius.circular(16.0), // 모서리 둥글게 설정
              ),
              child: DropdownButtonFormField<int>(
                value: selectedReps, // 현재 선택된 세트 당 운동횟수
                items: repsOptions.map((reps) => DropdownMenuItem(
                  value: reps, // 각 세트 당 운동횟수 값을 드롭다운 항목으로 설정
                  child: Text(
                    '$reps 회', // 세트 당 운동횟수 표시
                    style: TextStyle(
                      fontFamily: 'Roboto', // 폰트 설정
                      fontWeight: FontWeight.w600, // 글자 두께 설정
                      fontSize: 16.0, // 글자 크기 설정
                      color: Colors.black87, // 글자 색상 설정
                    ),
                  ),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedReps = value; // 선택된 세트 당 운동횟수 업데이트
                  });
                },
                decoration: InputDecoration(
                  labelText: '세트 당 운동횟수', // 라벨 텍스트 설정
                  labelStyle: TextStyle(
                    fontFamily: 'Roboto', // 폰트 설정
                    fontWeight: FontWeight.w600, // 글자 두께 설정
                    fontSize: 16.0, // 글자 크기 설정
                    color: Colors.black87, // 글자 색상 설정
                  ),
                  border: InputBorder.none, // 테두리 없음
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0), // 컨테이너 패딩 설정
              decoration: BoxDecoration(
                color: Colors.grey[100], // 배경색 설정
                borderRadius: BorderRadius.circular(16.0), // 모서리 둥글게 설정
              ),
              child: DropdownButtonFormField<int>(
                value: selectedSets, // 현재 선택된 세트 수
                items: setOptions.map((sets) => DropdownMenuItem(
                  value: sets, // 각 세트 수 값을 드롭다운 항목으로 설정
                  child: Text(
                    '$sets 세트', // 세트 수 표시
                    style: TextStyle(
                      fontFamily: 'Roboto', // 폰트 설정
                      fontWeight: FontWeight.w600, // 글자 두께 설정
                      fontSize: 16.0, // 글자 크기 설정
                      color: Colors.black87, // 글자 색상 설정
                    ),
                  ),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSets = value; // 선택된 세트 수 업데이트
                  });
                },
                decoration: InputDecoration(
                  labelText: '세트 수', // 라벨 텍스트 설정
                  labelStyle: TextStyle(
                    fontFamily: 'Roboto', // 폰트 설정
                    fontWeight: FontWeight.w600, // 글자 두께 설정
                    fontSize: 16.0, // 글자 크기 설정
                    color: Colors.black87, // 글자 색상 설정
                  ),
                  border: InputBorder.none, // 테두리 없음
                ),
              ),
            ), // 간격 추가

            SizedBox(height: 16.0), // 간격 추가
            ElevatedButton(
              onPressed: _addExercise, // 운동 추가 버튼 클릭 시 운동 추가 함수 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // 버튼 배경색 설정
                elevation: 4.0, // 그림자 효과 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // 버튼 모서리 둥글게 설정
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 패딩 설정
              ),
              child: Text(
                '운동 추가', // 버튼 텍스트
                style: TextStyle(
                  fontFamily: 'Bebas Neue', // 폰트 설정
                  fontSize: 20.0, // 글자 크기 설정
                  fontWeight: FontWeight.bold, // 글자 두께 설정
                  color: Colors.white, // 텍스트 색상 설정
                ),
              ),
            ),
            SizedBox(height: 16.0), // 간격 추가
            if (addedExercises.isNotEmpty) ...[
              Text(
                '추가된 운동 목록', // 추가된 운동 목록 제목
                style: TextStyle(
                  fontFamily: 'Roboto', // 폰트 설정
                  fontWeight: FontWeight.w600, // 글자 두께 설정
                  fontSize: 18.0, // 글자 크기 설정
                  color: Colors.black, // 글자 색상 설정
                ),
              ),
              SizedBox(height: 8.0), // 간격 추가
              ...addedExercises.asMap().entries.map((entry) {
                int index = entry.key; // 운동의 인덱스
                Map<String, dynamic> exercise = entry.value; // 운동 데이터
                return ListTile(
                  title: Text(
                    '${exercise['exercise']} - ${exercise['time']}초 동안 ${exercise['reps']}회, ${exercise['sets']}세트',// 운동 이름, 시간, 세트 수 표시
                    style: TextStyle(
                      fontFamily: 'Roboto', // 폰트 설정
                      fontSize: 16.0, // 글자 크기 설정
                      color: Colors.black87, // 글자 색상 설정
                    ),
                  ),
                  subtitle: Text('운동 부위: ${exercise['bodyPart']}'), // 운동 부위 표시
                  trailing: IconButton(
                    icon: Icon(Icons.delete), // 삭제 아이콘
                    onPressed: () => _removeExercise(index), // 삭제 버튼 클릭 시 운동 제거 함수 호출
                  ),
                );
              }).toList(),
            ],
            SizedBox(height: 32.0), // 간격 추가
            ElevatedButton(
              onPressed: _addRoutine, // 루틴 저장 버튼 클릭 시 루틴 저장 함수 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼 배경색 설정
                elevation: 4.0, // 그림자 효과 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // 버튼 모서리 둥글게 설정
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 패딩 설정
              ),
              child: Text(
                '루틴 저장', // 버튼 텍스트
                style: TextStyle(
                  fontFamily: 'Bebas Neue', // 폰트 설정
                  fontSize: 20.0, // 글자 크기 설정
                  fontWeight: FontWeight.bold, // 글자 두께 설정
                  color: Colors.white, // 텍스트 색상 설정
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 텍스트 필드를 생성하는 위젯이다
  Widget _buildTextField({
    required TextEditingController controller, // 입력을 제어하는 컨트롤러
    required String label, // 라벨 텍스트
    TextInputType keyboardType = TextInputType.text, // 키보드 타입 설정
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0), // 패딩 설정
      decoration: BoxDecoration(
        color: Colors.grey[100], // 배경색 설정
        borderRadius: BorderRadius.circular(16.0), // 모서리 둥글게 설정
      ),
      child: TextField(
        controller: controller, // 컨트롤러 연결
        decoration: InputDecoration(
          labelText: label, // 라벨 텍스트 설정
          labelStyle: TextStyle(
            fontFamily: 'Roboto', // 폰트 설정
            fontWeight: FontWeight.w600, // 글자 두께 설정
            fontSize: 16.0, // 글자 크기 설정
            color: Colors.black87, // 글자 색상 설정
          ),
          border: InputBorder.none, // 테두리 없음
        ),
        keyboardType: keyboardType, // 키보드 타입 설정
      ),
    );
  }
}

