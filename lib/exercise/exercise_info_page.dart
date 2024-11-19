// 운동 정보 페이지
import 'dart:convert'; // JSON 데이터를 인코딩 및 디코딩하기 위해 사용됨
import 'package:flutter/material.dart'; // Flutter의 기본 위젯들을 제공하는 패키지임
import 'package:flutter/services.dart'; // 애플리케이션의 자산(asset)에 접근하거나 시스템과의 상호작용을 위해 사용됨
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // 폰트어썸 아이콘을 사용하기 위해 필요함
import '../user_info_page.dart'; // 마이페이지로 이동하기 위해 import 추가

// ExerciseInfoPage는 운동 정보를 표시하고, 사용자가 운동을 선택하여 상세 정보를 확인할 수 있는 화면이다
class ExerciseInfoPage extends StatefulWidget {
  @override
  _ExerciseInfoPageState createState() => _ExerciseInfoPageState();
}

class _ExerciseInfoPageState extends State<ExerciseInfoPage> {
  List<Map<String, dynamic>> exercises = []; // 전체 운동 목록을 저장하는 리스트이다
  String? selectedBodyPart; // 현재 선택된 운동 부위를 저장하는 변수이다
  List<Map<String, dynamic>> filteredExercises = []; // 선택된 부위에 해당하는 운동 목록을 저장하는 리스트이다

  // 로컬 JSON 파일에서 운동 데이터를 로드하는 함수이다
  Future<void> _loadExercises() async {
    String data = await rootBundle.loadString('assets/exercise_data.json'); // assets 폴더의 exercise_data.json 파일을 로드함
    setState(() {
      exercises = List<Map<String, dynamic>>.from(json.decode(data)); // JSON 데이터를 디코딩하여 exercises 리스트에 저장함
    });
  }

  @override
  void initState() {
    super.initState();
    _loadExercises(); // 위젯이 초기화될 때 운동 데이터를 로드함
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedBodyPart == null ? '운동 정보' : selectedBodyPart!, // 선택된 부위가 없으면 '운동 정보' 제목을, 있으면 해당 부위 이름을 표시함
          style: TextStyle(
            fontFamily: 'Bebas Neue', // 폰트 적용
            fontSize: 28.0, // 폰트 크기 설정
            fontWeight: FontWeight.w900, // 폰트 두께 설정
            color: Colors.black, // 폰트 색상 설정
          ),
        ),
        backgroundColor: Colors.white, // 앱바 배경색을 흰색으로 설정함
        iconTheme: IconThemeData(color: Colors.black), // 앱바 아이콘 색상을 검은색으로 설정함
        leading: selectedBodyPart == null
            ? null
            : IconButton(
          onPressed: () {
            setState(() {
              selectedBodyPart = null; // 뒤로가기 버튼을 누르면 선택된 부위를 해제함
            });
          },
          icon: Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 아이콘을 검은색으로 설정함
        ),
        actions: [
          IconButton(
            onPressed: () {
              // 마이페이지로 이동하는 함수
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserInfoPage(), // UserInfoPage로 이동함
                  fullscreenDialog: true, // 전체 화면 다이얼로그로 표시함
                ),
              );
            },
            icon: const Icon(Icons.person, color: Colors.black), // 사람 아이콘을 검은색으로 설정함
          ),
        ],
      ),
      body: exercises.isEmpty
          ? Center(child: CircularProgressIndicator()) // 운동 데이터가 로드되지 않았으면 로딩 인디케이터를 표시함
          : selectedBodyPart == null
          ? _buildBodyPartSelection() // 선택된 부위가 없으면 부위 선택 화면을 표시함
          : _buildExerciseList(), // 선택된 부위가 있으면 해당 부위의 운동 목록을 표시함
    );
  }

  // 운동 부위를 선택할 수 있는 그리드 뷰를 생성하는 함수이다
  Widget _buildBodyPartSelection() {
    final bodyParts = [
      {'name': '가슴', 'icon': FontAwesomeIcons.userAlt}, // 가슴 부위와 관련된 아이콘
      {'name': '하체', 'icon': FontAwesomeIcons.shoePrints}, // 하체 부위와 관련된 아이콘
      {'name': '팔', 'icon': FontAwesomeIcons.handFist}, // 팔 부위와 관련된 아이콘
      {'name': '등', 'icon': FontAwesomeIcons.user}, // 등 부위와 관련된 아이콘
      {'name': '어깨', 'icon': FontAwesomeIcons.child}, // 어깨 부위와 관련된 아이콘
      {'name': '유산소', 'icon': FontAwesomeIcons.personRunning}, // 유산소 운동과 관련된 아이콘
    ];

    return GridView.builder(
      padding: EdgeInsets.all(24.0), // 그리드 패딩 설정
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 한 줄에 2개의 아이템을 표시함
        crossAxisSpacing: 16.0, // 가로 간격 설정
        mainAxisSpacing: 16.0, // 세로 간격 설정
      ),
      itemCount: bodyParts.length, // 그리드 아이템의 개수를 부위 리스트의 길이로 설정함
      itemBuilder: (context, index) {
        final bodyPart = bodyParts[index]; // 현재 인덱스의 부위 정보를 가져옴
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedBodyPart = bodyPart['name'] as String; // 선택된 부위를 업데이트함
              filteredExercises = exercises
                  .where((exercise) => exercise['bodyPart'] == bodyPart['name'])
                  .toList(); // 선택된 부위에 해당하는 운동 목록을 필터링함
            });
          },
          child: Card(
            elevation: 4.0, // 카드의 그림자 높이를 설정함
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // 카드의 외부 여백을 설정함
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // 카드의 모서리를 둥글게 설정함
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 열의 자식들을 중앙에 배치함
              children: [
                FaIcon(
                  bodyPart['icon'] as IconData, // 부위에 해당하는 아이콘을 표시함
                  size: 50.0, // 아이콘 크기를 설정함
                  color: Colors.blue, // 아이콘 색상을 파란색으로 설정함
                ),
                SizedBox(height: 10.0), // 아이콘과 텍스트 사이의 간격을 설정함
                Text(
                  bodyPart['name'] as String, // 부위 이름을 표시함
                  style: TextStyle(
                    fontFamily: 'Roboto', // 폰트 설정함
                    fontWeight: FontWeight.bold, // 글자 두께를 굵게 설정함
                    fontSize: 18.0, // 글자 크기를 설정함
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 선택된 부위의 운동 목록을 표시하는 리스트 뷰를 생성하는 함수이다
  Widget _buildExerciseList() {
    return ListView.builder(
      padding: EdgeInsets.all(24.0), // 리스트 패딩 설정
      itemCount: filteredExercises.length, // 리스트 아이템의 개수를 필터링된 운동 목록의 길이로 설정함
      itemBuilder: (context, index) {
        final exercise = filteredExercises[index]; // 현재 인덱스의 운동 정보를 가져옴
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseDetailPage(exercise: exercise), // 운동 상세 페이지로 이동함
                fullscreenDialog: true, // 전체 화면 다이얼로그로 표시함
              ),
            );
          },
          child: Card(
            elevation: 4.0, // 카드의 그림자 높이를 설정함
            margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0), // 카드의 외부 여백을 설정함
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // 카드의 모서리를 둥글게 설정함
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0), // 리스트 타일의 내부 여백을 설정함
              title: Text(
                exercise['name'], // 운동 이름을 표시함
                style: TextStyle(
                  fontFamily: 'Roboto', // 폰트 설정함
                  fontWeight: FontWeight.bold, // 글자 두께를 굵게 설정함
                  fontSize: 18.0, // 글자 크기를 설정함
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ExerciseDetailPage는 선택된 운동의 상세 정보를 표시하는 페이지이다
class ExerciseDetailPage extends StatelessWidget {
  final Map<String, dynamic> exercise; // 상세 정보를 표시할 운동 데이터

  ExerciseDetailPage({required this.exercise}); // 생성자에서 운동 데이터를 필수로 받음

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          exercise['name'], // 운동 이름을 앱바 제목으로 표시함
          style: TextStyle(
            fontFamily: 'Bebas Neue', // 폰트 적용함
            fontSize: 28.0, // 폰트 크기 설정함
            fontWeight: FontWeight.w900, // 폰트 두께 설정함
            color: Colors.black, // 폰트 색상 설정함
          ),
        ),
        backgroundColor: Colors.white, // 앱바 배경색을 흰색으로 설정함
        iconTheme: IconThemeData(color: Colors.black), // 앱바 아이콘 색상을 검은색으로 설정함
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼을 누르면 이전 화면으로 돌아감
          },
          icon: Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 아이콘을 검은색으로 설정함
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0), // 전체 패딩 설정함
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 자식 위젯들을 좌측 정렬함
          children: [
            Text(
              exercise['name'], // 운동 이름을 크게 표시함
              style: TextStyle(
                fontSize: 24.0, // 글자 크기를 설정함
                fontWeight: FontWeight.bold, // 글자 두께를 굵게 설정함
                color: Colors.black, // 글자 색상을 검은색으로 설정함
                fontFamily: 'Roboto', // 폰트 설정함
              ),
            ),
            SizedBox(height: 16.0), // 글자와 다음 항목 사이의 간격을 설정함
            Text(
              '운동 부위: ${exercise['bodyPart']}', // 운동 부위를 표시함
              style: TextStyle(
                fontSize: 18.0, // 글자 크기를 설정함
                fontWeight: FontWeight.w500, // 글자 두께를 중간으로 설정함
                color: Colors.black54, // 글자 색상을 회색으로 설정함
                fontFamily: 'Roboto', // 폰트 설정함
              ),
            ),
            SizedBox(height: 8.0), // 글자와 다음 항목 사이의 간격을 설정함
            Text(
              '설명: ${exercise['description']}', // 운동 설명을 표시함
              style: TextStyle(
                fontSize: 16.0, // 글자 크기를 설정함
                color: Colors.black, // 글자 색상을 검은색으로 설정함
                fontFamily: 'Roboto', // 폰트 설정함
              ),
            ),
          ],
        ),
      ),
    );
  }
}
