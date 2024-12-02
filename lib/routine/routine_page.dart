//루틴 관리 페이지
import 'dart:convert'; // JSON 인코딩 및 디코딩을 위해 사용
import 'package:flutter/material.dart'; // Flutter의 위젯들을 사용하기 위해 임포트
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 저장소에 데이터 저장을 위해 사용
import 'add_routine_page.dart'; // 루틴 추가 페이지를 위한 임포트
import 'routine_detail_page.dart'; // 루틴 상세 페이지를 위한 임포트
import '../user_info_page.dart'; // 사용자 정보 페이지를 위한 임포트

// 루틴 관리를 위한 StatefulWidget을 선언
class RoutinePage extends StatefulWidget {
  @override
  _RoutinePageState createState() => _RoutinePageState();
}

// RoutinePage의 상태를 관리하는 클래스
class _RoutinePageState extends State<RoutinePage> {
  // 루틴 정보를 담는 리스트를 선언
  List<Map<String, dynamic>> routines = [];

  @override
  void initState() {
    super.initState();
    _loadRoutines(); // 위젯이 초기화될 때 저장된 루틴들을 불러옴
  }

  // 저장된 루틴들을 로컬 저장소에서 불러오는 함수
  void _loadRoutines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedRoutines = prefs.getString('routines');
    if (savedRoutines != null) {
      setState(() {
        // JSON 문자열을 맵(Map)의 리스트로 변환하여 routines에 저장
        routines = List<Map<String, dynamic>>.from(json.decode(savedRoutines) as List);
      });
    }
  }

  // 현재의 루틴 리스트를 로컬 저장소에 저장하는 함수
  void _saveRoutines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // routines 리스트를 JSON 문자열로 변환하여 저장
    await prefs.setString('routines', json.encode(routines));
  }

  // 새로운 루틴을 추가하는 함수
  void _addNewRoutine(Map<String, dynamic> routine) {
    setState(() {
      // 루틴에 createdAt 필드가 없으면 현재 시간을 추가
      if(!routine.containsKey('createdAt')){
        routine['createdAt'] = DateTime.now().toIso8601String(); // createdAt 필드 추가
      }
      routines.add(routine); // 새로운 루틴을 리스트에 추가
      _saveRoutines(); // 업데이트된 리스트를 저장
    });
  }

  // 기존 루틴을 업데이트하는 함수
  void _updateRoutine(int index, Map<String, dynamic> updatedRoutine) {
    setState(() {
      routines[index] = updatedRoutine; // 해당 인덱스의 루틴을 업데이트
      _saveRoutines(); // 업데이트된 리스트를 저장
    });
  }

  // 루틴을 삭제하는 함수
  void _removeRoutine(int index) {
    setState(() {
      routines.removeAt(index); // 해당 인덱스의 루틴을 리스트에서 제거
      _saveRoutines(); // 업데이트된 리스트를 저장
    });
  }

  // 루틴 추가 페이지로 이동하는 함수
  void _goToAddRoutinePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRoutinePage(), // AddRoutinePage로 이동
        fullscreenDialog: true, // 전체 화면 다이얼로그로 표시
      ),
    );
    if (result != null) {
      _addNewRoutine(result); // 추가된 루틴을 리스트에 반영
    }
  }

  // 루틴 상세 페이지로 이동하는 함수
  void _goToRoutineDetailPage(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineDetailPage(
          routine: routines[index], // 선택된 루틴을 전달
          onSave: (updatedRoutine) {
            _updateRoutine(index, updatedRoutine); // 루틴이 업데이트되면 리스트에 반영
          },
          onDelete: () {
            _removeRoutine(index); // 루틴이 삭제되면 리스트에서 제거
          },
        ),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      setState(() {
        _saveRoutines(); // 변경 사항을 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단의 앱바를 정의
      appBar: AppBar(
        title: Text(
          '루틴 관리', // 앱의 제목을 설정
          style: TextStyle(
            fontFamily: 'Bebas Neue', // 폰트 설정
            fontSize: 28.0, // 폰트 크기 설정
            fontWeight: FontWeight.w900, // 폰트 굵기 설정
            color: Colors.black, // 폰트 색상 설정
          ),
        ),
        backgroundColor: Colors.white, // 앱바 배경색 설정
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 설정
        actions: [
          // 사용자 정보 페이지로 이동하는 아이콘 버튼을 추가
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserInfoPage(), // UserInfoPage로 이동
                  fullscreenDialog: true,
                ),
              );
            },
            icon: const Icon(Icons.person, color: Colors.black), // 아이콘 설정
          ),
        ],
      ),
      // 본문 영역을 정의
      body: routines.isEmpty
          ? const Center(
        // 루틴이 없을 경우 표시할 내용
        child: Text(
          '등록된 루틴이 없습니다.',
          style: TextStyle(
            fontFamily: 'Roboto', // 폰트 설정
            fontSize: 18.0, // 폰트 크기 설정
            fontWeight: FontWeight.w600, // 폰트 굵기 설정
            color: Colors.black54, // 폰트 색상 설정
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        // 루틴 목록을 리스트뷰로 표시
        child: ListView.builder(
          itemCount: routines.length, // 루틴의 개수를 아이템 수로 설정
          itemBuilder: (context, index) {
            final routine = routines[index]; // 각 루틴을 가져옴
            // 생성 시간을 DateTime 객체로 피싱
            DateTime createdAt = DateTime.parse(routine['createdAt'] ?? DateTime.now().toIso8601String());
            // 생성 시간을 원하는 형식으로 포맷
            String formattedDate = "${createdAt.year}-${createdAt.month}-${createdAt.day}-${createdAt.hour}:${createdAt.minute}";
            return GestureDetector(
              onTap: () {
                _goToRoutineDetailPage(index); // 루틴을 탭하면 상세 페이지로 이동
              },
              child: Card(
                elevation: 4.0, // 그림자 효과를 추가
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // 카드의 모서리를 둥글게 설정
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0), // 콘텐츠의 여백을 설정
                  title: Text(
                    routine['name'], // 루틴의 이름을 표시
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, // 폰트 굵기 설정
                      fontSize: 18.0, // 폰트 크기 설정
                      fontFamily: 'Roboto', // 폰트 설정
                    ),
                  ),
                  subtitle: Text(
                    "생성일: $formattedDate", // 생성된 날짜와 시간을 표시
                    style: TextStyle(
                      fontSize: 14.0, // 폰트 크기 설정
                      color: Colors.black54,//
                    ),
                  ),
                  // 오른쪽에 삭제 아이콘 버튼 추가
                  trailing:  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.black,
                    onPressed: () {
                      _removeRoutine(index); // 삭제 함수 호출
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
      // 화면 하단에 플로팅 액션 버튼을 추가
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddRoutinePage, // 버튼을 누르면 루틴 추가 페이지로 이동
        backgroundColor: Colors.blueAccent, // 버튼 배경색 설정
        child: const Icon(
          Icons.add, // 플러스 아이콘을 표시
          color: Colors.white, // 아이콘 색상 설정
        ),
      ),
    );
  }
}

