
// 루틴 상세 페이지
import 'dart:convert'; // JSON 데이터를 인코딩 및 디코딩하기 위해 사용
import 'package:flutter/material.dart'; // Flutter의 기본 위젯들을 제공하는 패키지
import 'package:flutter/services.dart'; // 애플리케이션의 자산(asset)에 접근하거나 시스템과의 상호작용을 위해 사용

// RoutineDetailPage는 루틴의 상세 정보를 표시하고 수정할 수 있는 화면이다
class RoutineDetailPage extends StatefulWidget {
  final Map<String, dynamic> routine; // 표시할 루틴 데이터
  final Function(Map<String, dynamic>) onSave; // 루틴 저장 시 호출되는 함수
  final Function() onDelete; // 루틴 삭제 시 호출되는 함수

  RoutineDetailPage({
    required this.routine,
    required this.onSave,
    required this.onDelete,
  });

  @override
  _RoutineDetailPageState createState() => _RoutineDetailPageState();
}

class _RoutineDetailPageState extends State<RoutineDetailPage> {
  final TextEditingController nameController = TextEditingController(); // 루틴 이름을 입력하는 컨트롤러
  String? selectedBodyPart; // 선택된 운동 부위
  List<String> bodyParts = ['가슴', '하체', '팔', '등', '어깨', '유산소']; // 운동 부위 옵션 리스트 (운동 정보 페이지와 일치)
  List<Map<String, dynamic>> exercises = []; // 루틴에 포함된 운동 목록
  List<Map<String, dynamic>> allExercises = []; // 모든 운동 데이터 목록
  List<String> filteredExercises = []; // 선택된 운동 부위에 따른 운동 목록
  List<int> secondsOptions = List.generate(60, (index) => index + 1); // 시간 선택 옵션 (1초부터 60초까지)
  List<int> setOptions = List.generate(10, (index) => index + 1); // 세트 수 선택 옵션 (1세트부터 10세트까지)
  List<int> repsOptions = List.generate(50,(index) => index+1); // 세트 당 운동 횟수 선택 옵션(1회부터 50회까지)

  @override
  void initState() {
    super.initState();
    _loadRoutineData(); // 초기 루틴 데이터 로드
    _loadExercises(); // 운동 목록 로드
  }

  // 루틴 데이터를 로드하여 초기화한다
  void _loadRoutineData() {
    nameController.text = widget.routine['name']; // 루틴 이름 설정
    exercises = List<Map<String, dynamic>>.from(widget.routine['exercises']); // 운동 목록 설정
  }

  // 로컬 JSON 파일에서 운동 데이터를 로드한다
  Future<void> _loadExercises() async {
    String data = await rootBundle.loadString('assets/exercise_data.json'); // JSON 파일 로드
    setState(() {
      allExercises = List<Map<String, dynamic>>.from(json.decode(data)); // 모든 운동 데이터 설정
    });
  }

  // 루틴을 저장하고 이전 화면으로 돌아간다
  void _saveRoutine() {
    if (nameController.text.isNotEmpty && exercises.isNotEmpty) { // 유효성 검사
      final updatedRoutine = {
        'name': nameController.text, // 루틴 이름 업데이트
        'exercises': exercises, // 운동 목록 업데이트
      };
      widget.onSave(updatedRoutine); // 저장 함수 호출
      Navigator.pop(context); // 화면 닫기
    } else {
      // 유효하지 않은 입력 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('올바른 정보를 입력해주세요.')), // 오류 메시지 표시
      );
    }
  }


  // 루틴을 삭제하고 이전 화면으로 돌아간다
  void _deleteRoutine() {
    widget.onDelete(); // 삭제 함수 호출
    Navigator.pop(context); // 화면 닫기
  }



  @override
  void dispose() {
    nameController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 앱바 배경색 설정
        title: Text(
          '루틴 상세', // 앱바 제목
          style: TextStyle(
            fontFamily: 'Bebas Neue', // 폰트 설정
            fontSize: 28.0, // 글자 크기 설정
            fontWeight: FontWeight.w900, // 글자 두께 설정
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 설정
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // 전체 패딩 설정
        child: ListView(
          children: [
            Text(
              '루틴 이름:', // 루틴 이름 레이블
              style: TextStyle(
                fontFamily: 'Roboto', // 폰트 설정
                fontSize: 18.0, // 글자 크기 설정
                fontWeight: FontWeight.bold, // 글자 두께 설정
              ),
            ),
            _buildTextField(
              controller: nameController, // 루틴 이름 텍스트 필드 컨트롤러 연결
              label: '루틴 이름', // 텍스트 필드 라벨
              hintText: '루틴 이름을 입력하세요', // 텍스트 필드 힌트
            ),
            SizedBox(height: 16.0), // 간격 추가
            if (exercises.isNotEmpty) ...[
              Text(
                '추가된 운동 목록:', // 운동 목록 제목
                style: TextStyle(
                  fontFamily: 'Roboto', // 폰트 설정
                  fontWeight: FontWeight.bold, // 글자 두께 설정
                  fontSize: 18.0, // 글자 크기 설정
                  color: Colors.black, // 글자 색상 설정
                ),
              ),
              SizedBox(height: 8.0), // 간격 추가
              // 운동 목록을 리스트 형태로 표시
              ...exercises.asMap().entries.map((entry) {
                int index = entry.key; // 운동의 인덱스
                Map<String, dynamic> exercise = entry.value; // 운동 데이터
                return ListTile(
                  title: Text(
                    '${exercise['exercise']} - ${exercise['time']}초 동안 ${exercise['reps']}회 X ${exercise['sets']}세트', // 운동 정보 표시
                    style: TextStyle(
                      fontFamily: 'Roboto', // 폰트 설정
                      fontSize: 16.0, // 글자 크기 설정
                      color: Colors.black87, // 글자 색상 설정
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.black), // 옵션 아이콘 설정
                    onPressed: () => _showEditExerciseOptions(index), // 옵션 버튼 클릭 시 편집 옵션 표시
                  ),
                );
              }).toList(),
            ],

            SizedBox(height: 32.0), // 간격 추가
            ElevatedButton(
              onPressed: _showAddExerciseForm, // 운동 추가 폼 표시
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // 버튼 배경색
                elevation: 4.0, // 그림자 효과
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // 둥근 모서리
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 패딩
              ),
              child: Text(
                '운동 추가', // 버튼 텍스트
                style: TextStyle(
                  fontFamily: 'Bebas Neue', // 폰트
                  fontSize: 20.0, // 글자 크기
                  fontWeight: FontWeight.bold, // 글자 두께
                  color: Colors.white, // 텍스트 색상
                ),
              ),
            ),


            SizedBox(height: 16.0), // 간격 추가
            ElevatedButton(
              onPressed: _saveRoutine, // 저장 버튼 클릭 시 루틴 저장
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼 배경색 설정
                elevation: 4.0, // 그림자 효과 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // 버튼 모서리 둥글게 설정
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 패딩 설정
              ),
              child: Text(
                '저장', // 버튼 텍스트
                style: TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // 텍스트 색상 설정
                ),
              ),
            ),
            SizedBox(height: 16.0), // 간격 추가
            ElevatedButton(
              onPressed: _deleteRoutine, // 삭제 버튼 클릭 시 루틴 삭제
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // 버튼 배경색 설정
                elevation: 4.0, // 그림자 효과 설정
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

  // 운동 추가 폼 표시 메소드
  void _showAddExerciseForm() {
    String? selectedBodyPart; // 선택된 운동 부위
    List<String> filteredExercises = []; // 필터링된 운동 목록
    String? selectedExercise; // 선택된 운동
    int? selectedTime; // 선택된 운동 시간
    int? selectedSets; // 선택된 세트 수
    int? selectedReps; // 선택된 세트당 운동 횟수

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드가 올라올 때 스크롤 가능
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // 키보드 높이에 맞게 패딩 조절
              child: Padding(
                padding: const EdgeInsets.all(16.0), // 전체 패딩
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 운동 부위 선택
                    DropdownButtonFormField<String>(
                      value: selectedBodyPart, // 선택된 운동 부위
                      items: bodyParts.map((part) => DropdownMenuItem(
                        value: part,
                        child: Text(
                          part,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedBodyPart = value; // 운동 부위 업데이트
                          filteredExercises = allExercises
                              .where((exercise) => exercise['bodyPart'] == selectedBodyPart) // 운동 목록 필터링
                              .map((exercise) => exercise['name'] as String)
                              .toList();
                          selectedExercise = null; // 운동 초기화
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '운동 부위',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // 운동 이름 선택
                    DropdownButtonFormField<String>(
                      value: selectedExercise,
                      items: filteredExercises.map((exerciseName) => DropdownMenuItem(
                        value: exerciseName,
                        child: Text(
                          exerciseName,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedExercise = value; // 운동 이름 업데이트
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '운동 이름',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // 운동 시간 선택
                    DropdownButtonFormField<int>(
                      value: selectedTime,
                      items: secondsOptions.map((seconds) => DropdownMenuItem(
                        value: seconds,
                        child: Text('$seconds 초',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedTime = value; // 운동 시간 업데이트
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '운동 시간 (초)',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    DropdownButtonFormField<int>(
                      value: selectedReps,
                      items: repsOptions.map((reps) => DropdownMenuItem(
                        value: reps,
                        child: Text('$reps 회',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedReps = value; // 세트 당 운동 횟수 업데이트
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '세트 당 운동 횟수',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // 세트 수 선택
                    DropdownButtonFormField<int>(
                      value: selectedSets,
                      items: setOptions.map((sets) => DropdownMenuItem(
                        value: sets,
                        child: Text('$sets 세트',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedSets = value; // 세트 수 업데이트
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '세트 수',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.0),

                    ElevatedButton(
                      onPressed: () {
                        if (selectedBodyPart != null &&
                            selectedExercise != null &&
                            selectedTime != null &&
                            selectedSets != null &&
                            selectedReps != null) {
                          setState(() {
                            exercises.add({
                              'bodyPart': selectedBodyPart,
                              'exercise': selectedExercise,
                              'time': selectedTime,
                              'sets': selectedSets,
                              'reps': selectedReps,
                            }); // 운동 추가
                          });
                          Navigator.pop(context); // 모달 닫기
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('모든 정보를 입력해주세요.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text(
                        '추가',
                        style: TextStyle(
                          fontFamily: 'Bebas Neue',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  } //void _showAddExerciseForm()


  // 운동 항목에 대한 편집 옵션을 보여주는 함수
  void _showEditExerciseOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0), // 패딩 설정
          child: Column(
            mainAxisSize: MainAxisSize.min, // 최소 크기 설정
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.black), // 수정 아이콘
                title: Text('운동 수정'), // 수정 옵션 제목
                onTap: () {
                  Navigator.pop(context); // 모달 닫기
                  _showEditExerciseForm(index); // 운동 수정 폼 표시
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.black), // 삭제 아이콘
                title: Text('운동 삭제'), // 삭제 옵션 제목
                onTap: () {
                  Navigator.pop(context); // 모달 닫기
                  setState(() {
                    exercises.removeAt(index); // 해당 운동 삭제
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 운동 항목을 수정할 수 있는 폼을 보여주는 함수
  void _showEditExerciseForm(int index) {
    String? selectedBodyPart = exercises[index]['bodyPart']; // 선택된 운동 부위 설정

    // 선택된 운동 부위에 따라 운동 목록 필터링
    filteredExercises = selectedBodyPart != null
        ? allExercises
        .where((exercise) => exercise['bodyPart'] == selectedBodyPart) // 선택된 운동 부위에 해당하는 운동 필터링
        .map((exercise) => exercise['name'] as String)
        .toList()
        : [];

    String? selectedExercise = exercises[index]['exercise']; // 선택된 운동 이름 설정
    if (selectedExercise != null && !filteredExercises.contains(selectedExercise)) {
      selectedExercise = null; // 현재 선택된 운동이 필터링된 목록에 없다면 null로 설정합니다.
    }

    final TextEditingController timeController =
    TextEditingController(text: exercises[index]['time'].toString()); // 운동 시간 컨트롤러 설정
    final TextEditingController setsController =
    TextEditingController(text: exercises[index]['sets'].toString()); // 세트 수 컨트롤러 설정

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드가 올라올 때 스크롤 가능하게 설정
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // 키보드 높이에 따라 패딩 조절
              child: Padding(
                padding: const EdgeInsets.all(16.0), // 내부 패딩 설정
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 컨텐츠에 맞게 크기 조절
                  children: [
                    // 운동 부위 선택
                    DropdownButtonFormField<String>(
                      value: bodyParts.contains(selectedBodyPart) ? selectedBodyPart : null, // 선택된 운동 부위 설정
                      items: bodyParts.map((part) => DropdownMenuItem(
                        value: part,
                        child: Text(
                          part,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedBodyPart = value; // 선택된 운동 부위 업데이트
                          filteredExercises = allExercises
                              .where((exercise) => exercise['bodyPart'] == selectedBodyPart) // 선택된 운동 부위에 따라 운동 필터링
                              .map((exercise) => exercise['name'] as String)
                              .toList();
                          exercises[index]['bodyPart'] = value; // 운동 부위 업데이트
                          selectedExercise = null; // 운동 종류를 다시 선택하도록 초기화합니다.
                          exercises[index]['exercise'] = null; // 운동 이름 초기화
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '운동 부위',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      hint: Text('운동 부위를 선택하세요'), // 힌트 텍스트 추가
                    ),
                    SizedBox(height: 16.0),
                    // 운동 종류 선택 (운동 부위에 따라 필터링된 목록)
                    DropdownButtonFormField<String>(
                      value: filteredExercises.contains(selectedExercise) ? selectedExercise : null, // 선택된 운동 설정
                      items: filteredExercises.map((exerciseName) => DropdownMenuItem(
                        value: exerciseName,
                        child: Text(
                          exerciseName,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedExercise = value; // 선택된 운동 업데이트
                          exercises[index]['exercise'] = value; // 운동 이름 업데이트
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '운동 이름',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      hint: Text('운동을 선택하세요'), // 힌트 텍스트 추가
                    ),
                    SizedBox(height: 16.0),
                    // 운동 시간 선택
                    DropdownButtonFormField<int>(
                      value: secondsOptions.contains(exercises[index]['time']) ? exercises[index]['time'] : null, // 선택된 시간 설정
                      items: secondsOptions.map((seconds) => DropdownMenuItem(
                        value: seconds,
                        child: Text(
                          '$seconds 초',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          exercises[index]['time'] = value; // 운동 시간 업데이트
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '시간 (초)',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      hint: Text('시간을 선택하세요'), // 힌트 텍스트 추가
                    ),
                    SizedBox(height: 16.0),
                    // 세트 수 선택

                    // 세트 당 운동 횟수 선택
                    DropdownButtonFormField<int>(
                      value: repsOptions.contains(exercises[index]['reps']) ? exercises[index]['reps'] : null, // 선택된 세트 당 운동 횟수 설정
                      items: repsOptions.map((reps) => DropdownMenuItem(
                        value: reps,
                        child: Text(
                          '$reps 회',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          exercises[index]['reps'] = value; // 세트 당 운동횟수 업데이트
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '세트 당 운동 횟수',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      hint: Text('세트 수를 선택하세요'), // 힌트 텍스트 추가
                    ),
                    SizedBox(height: 16.0),

                    DropdownButtonFormField<int>(
                      value: setOptions.contains(exercises[index]['sets']) ? exercises[index]['sets'] : null, // 선택된 세트 수 설정
                      items: setOptions.map((sets) => DropdownMenuItem(
                        value: sets,
                        child: Text(
                          '$sets 세트',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          exercises[index]['sets'] = value; // 세트 수 업데이트
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '세트 수',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      hint: Text('세트 수를 선택하세요'), // 힌트 텍스트 추가
                    ),
                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedBodyPart != null &&
                            exercises[index]['exercise'] != null &&
                            exercises[index]['time'] != null &&
                            exercises[index]['sets'] != null &&
                            exercises[index]['reps'] != null) {
                          setState(() {
                            exercises[index] = {
                              'exercise': exercises[index]['exercise'], // 운동 이름 업데이트
                              'bodyPart': selectedBodyPart, // 운동 부위 업데이트
                              'time': exercises[index]['time'], // 운동 시간 업데이트
                              'sets': exercises[index]['sets'], // 세트 수 업데이트
                              'reps': exercises[index]['reps'], // 세트 당 운동 횟수 업데이트
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
      },
    );
  }

  // 일관된 스타일의 텍스트 필드를 생성하는 헬퍼 메소드
  Widget _buildTextField({
    required TextEditingController controller, // 입력을 제어하는 컨트롤러
    required String label, // 라벨 텍스트
    String? hintText, // 힌트 텍스트
    TextInputType keyboardType = TextInputType.text, // 키보드 타입 설정 (기본값: 텍스트)
    Function(String)? onChanged, // 입력 변경 시 호출되는 함수
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
        onChanged: onChanged, // 입력 변경 시 함수 호출
      ),
    );
  }
}
