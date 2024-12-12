//루틴 관리 페이지
import 'dart:convert'; // JSON 인코딩 및 디코딩을 위해 사용
import 'package:flutter/material.dart'; // Flutter의 위젯들을 사용하기 위해 임포트
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 저장소에 데이터 저장을 위해 사용
import 'add_routine_page.dart'; // 루틴 추가 페이지를 위한 임포트
import 'routine_detail_page.dart'; // 루틴 상세 페이지를 위한 임포트
import '../user_info_page.dart'; // 사용자 정보 페이지를 위한 임포트

// 루틴 관리 화면
class RoutinePage extends StatefulWidget {
  @override
  _RoutinePageState createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  // 저장된 루틴 정보를 담는 리스트
  List<Map<String, dynamic>> routines = [];

  @override
  void initState() {
    super.initState();
    _loadRoutines(); // 초기화 시 저장된 루틴 불러오기
  }

  // 로컬 저장소에서 루틴 데이터를 불러옴
  void _loadRoutines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedRoutines = prefs.getString('routines');
    if (savedRoutines != null) {
      setState(() {
        routines = List<Map<String, dynamic>>.from(json.decode(savedRoutines));
      });
    }
  }

  // 현재 루틴 리스트를 로컬 저장소에 저장
  void _saveRoutines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('routines', json.encode(routines));
  }

  // 새로운 루틴 추가
  void _addNewRoutine(Map<String, dynamic> routine) {
    setState(() {
      if (!routine.containsKey('createdAt')) {
        routine['createdAt'] = DateTime.now().toIso8601String();
      }
      routines.add(routine);
      _saveRoutines(); // 업데이트 후 저장
    });
  }

  // 기존 루틴 업데이트
  void _updateRoutine(int index, Map<String, dynamic> updatedRoutine) {
    setState(() {
      routines[index] = updatedRoutine;
      _saveRoutines(); // 변경사항 저장
    });
  }

  // 루틴 삭제
  void _removeRoutine(int index) {
    setState(() {
      routines.removeAt(index);
      _saveRoutines(); // 삭제 후 저장
    });
  }

  // 루틴 추가 페이지로 이동
  void _goToAddRoutinePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRoutinePage(),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      _addNewRoutine(result); // 새 루틴 추가
    }
  }

  // 루틴 상세 페이지로 이동
  void _goToRoutineDetailPage(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineDetailPage(
          routine: routines[index],
          onSave: (updatedRoutine) => _updateRoutine(index, updatedRoutine),
          onDelete: () => _removeRoutine(index),
        ),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      setState(() {
        _saveRoutines(); // 변경 사항 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '루틴 관리',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 28.0,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // 사용자 정보 페이지로 이동
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserInfoPage(),
                  fullscreenDialog: true,
                ),
              );
            },
            icon: const Icon(Icons.person, color: Colors.black),
          ),
        ],
      ),
      // 루틴 리스트 또는 빈 상태 표시
      body: routines.isEmpty
          ? const Center(
        child: Text(
          '등록된 루틴이 없습니다.',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: ListView.builder(
          itemCount: routines.length,
          itemBuilder: (context, index) {
            final routine = routines[index];
            DateTime createdAt = DateTime.parse(
                routine['createdAt'] ?? DateTime.now().toIso8601String());
            String formattedDate =
                "${createdAt.year}-${createdAt.month}-${createdAt.day} ${createdAt.hour}:${createdAt.minute}";
            return GestureDetector(
              onTap: () => _goToRoutineDetailPage(index),
              child: Card(
                color: Colors.white,
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: const BorderSide(color: Colors.black, width: 1.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    routine['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  subtitle: Text(
                    "생성일: $formattedDate",
                    style: const TextStyle(fontSize: 14.0, color: Colors.black54),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.black,
                    onPressed: () => _showDeleteRoutineDialog(index),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      // 루틴 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddRoutinePage,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 삭제 확인 다이얼로그
  void _showDeleteRoutineDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            '삭제 확인',
            style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 20.0),
          ),
          content: const Text(
            '정말 삭제하시겠습니까?',
            style: TextStyle(fontFamily: 'Roboto', fontSize: 16.0),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto', fontSize: 14.0),
              ),
            ),
            TextButton(
              onPressed: () {
                _removeRoutine(index);
                Navigator.of(context).pop();
              },
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red, fontFamily: 'Roboto', fontSize: 14.0),
              ),
            ),
          ],
        );
      },
    );
  }
}

