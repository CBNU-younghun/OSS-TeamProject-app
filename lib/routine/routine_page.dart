import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_routine_page.dart';
import 'routine_detail_page.dart';
import '../user_info_page.dart';

enum SortOption { name, createdAt, lastUpdated }

class RoutinePage extends StatefulWidget {
  @override
  _RoutinePageState createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  List<Map<String, dynamic>> routines = [];
  SortOption _currentSortOption = SortOption.createdAt;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  void _loadRoutines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedRoutines = prefs.getString('routines');
    if (savedRoutines != null) {
      setState(() {
        routines = List<Map<String, dynamic>>.from(json.decode(savedRoutines));
        _sortRoutines(_currentSortOption);
      });
    }
  }

  void _saveRoutines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('routines', json.encode(routines));
  }

  void _addNewRoutine(Map<String, dynamic> routine) {
    setState(() {
      if (!routine.containsKey('createdAt')) {
        routine['createdAt'] = DateTime.now().toIso8601String();
      }
      routines.add(routine);
      _sortRoutines(_currentSortOption);
      _saveRoutines();
    });
  }

  void _updateRoutine(int index, Map<String, dynamic> updatedRoutine) {
    setState(() {
      routines[index] = updatedRoutine;
      routines[index]['lastUpdated'] = DateTime.now().toIso8601String();
      _sortRoutines(_currentSortOption);
      _saveRoutines();
    });
  }

  void _removeRoutine(int index) {
    setState(() {
      routines.removeAt(index);
      _saveRoutines();
    });
  }

  void _sortRoutines(SortOption option) {
    setState(() {
      _currentSortOption = option;
      switch (option) {
        case SortOption.name:
          routines.sort((a, b) => a['name'].compareTo(b['name']));
          break;
        case SortOption.createdAt:
          routines.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
          break;
        case SortOption.lastUpdated:
          routines.sort((a, b) => DateTime.parse(b['lastUpdated'] ?? b['createdAt'])
              .compareTo(DateTime.parse(a['lastUpdated'] ?? a['createdAt'])));
          break;
      }
    });
  }

  void _goToAddRoutinePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRoutinePage(),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      _addNewRoutine(result);
    }
  }

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
        _saveRoutines();
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
          PopupMenuButton<SortOption>(
            onSelected: _sortRoutines,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.name,
                child: Text('이름순'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.createdAt,
                child: Text('생성일순'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.lastUpdated,
                child: Text('최근 수정순'),
              ),
            ],
            icon: Icon(Icons.sort),
          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddRoutinePage,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

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
            '정말 루틴을 삭제하시겠습니까?',
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
