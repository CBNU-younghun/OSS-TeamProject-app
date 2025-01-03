// 운동 정보 페이지
import 'dart:convert'; // JSON 데이터를 인코딩 및 디코딩하기 위해 사용됨
import 'package:flutter/material.dart'; // Flutter의 기본 위젯들을 제공하는 패키지임
import 'package:flutter/services.dart'; // 애플리케이션의 자산(asset)에 접근하거나 시스템과의 상호작용을 위해 사용됨
import 'package:oss_team_project_app/providers/CrabAnimationProvider.dart';
import '../user_info_page.dart'; // 마이페이지로 이동하기 위해 import 추가
import 'package:oss_team_project_app/utils/CrabAnimation.dart';
import 'package:provider/provider.dart';
import 'favorite_exercise.dart';


// ExerciseInfoPage는 운동 정보를 표시하고, 사용자가 운동을 선택하여 상세 정보를 확인할 수 있는 화면이다
class ExerciseInfoPage extends StatefulWidget {
  @override
  _ExerciseInfoPageState createState() => _ExerciseInfoPageState();
}

class _ExerciseInfoPageState extends State<ExerciseInfoPage> {
  List<Map<String, dynamic>> exercises = []; // 전체 운동 목록을 저장하는 리스트이다
  String? selectedBodyPart; // 현재 선택된 운동 부위를 저장하는 변수이다
  List<Map<String, dynamic>> filteredExercises = []; // 선택된 부위에 해당하는 운동 목록을 저장하는 리스트이다
  String searchQuery = ""; //검색 쿼리(사용자 입력)를 저장하기 위한 변수
  final favoriteService = FavoriteService();
  bool showFavoritesOnly = false; // bookmark 필터 상태
  String? selectedFilter = 'all';

  // 로컬 JSON 파일에서 운동 데이터를 로드하는 함수이다
  Future<void> _loadExercises() async {
    // assets 폴더의 exercise_data.json 파일을 로드함
    String data = await rootBundle.loadString('assets/exercise_data.json');
    setState(() {
      // JSON 데이터를 디코딩하여 exercises 리스트에 저장함
      exercises = List<Map<String, dynamic>>.from(json.decode(data));
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await favoriteService.init();
      await _loadExercises();
    } catch (e) {
      print('에러가 발생했습니다: $e');
    } finally {
      setState(() {});
    }
  }

  // 현재 선택된 카테고리를 기반으로 필터링한 운동 가져오기
  List<Map<String, dynamic>> get filteredCategory {
    List<Map<String, dynamic>> result = exercises;
        if (searchQuery.toLowerCase() == "대게먹고싶다") {    //이스터에그
      return [
        {
          'name': '대게먹고싶다',
          'englishName': 'Want to eat crab'
        }
      ];
    }

    if (selectedFilter == 'bookmark') {
      showFavoritesOnly = true;
    } else {
      showFavoritesOnly = false;
    }

    // Bookmark 필터링
    if (showFavoritesOnly) {
      result = result.where((exercise) => favoriteService.isFavorite(exercise)).toList();
    }
    // 운동 부위 필터링
    if (selectedBodyPart != null) {
      result = result.where((exercise) => exercise['bodyPart'] == selectedBodyPart).toList();
    }
    // 검색 필터링
    if (searchQuery.isNotEmpty) {
      result = result.where((exercise) {
        return exercise['name'].toLowerCase().contains(searchQuery) ||
            exercise['englishName'].toLowerCase().contains(searchQuery) ||
            exercise['difficulty'].toLowerCase().contains(searchQuery);
      }).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            '운동 정보',
            style: TextStyle(
              fontFamily: 'Roboto', // 폰트 적용
              fontSize: 28.0, // 폰트 크기 설정
              fontWeight: FontWeight.w900, // 폰트 두께 설정
              color: Colors.black, // 폰트 색상 설정
            ),
          ),
          backgroundColor: Colors.white, // 앱바 배경색을 흰색으로 설정함
          iconTheme: const IconThemeData(color: Colors.black), // 앱바 아이콘 색상을 검은색으로 설정함
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
              icon: const Icon(
                  Icons.person, color: Colors.black), // 사람 아이콘을 검은색으로 설정함
            ),
          ],
        ),
        body: exercises.isEmpty
            ? const Center(child: CircularProgressIndicator()) // 운동 데이터가 로드되지 않았으면 로딩 인디케이터를 표시함
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20.0,
                right: 20.0,
                bottom: 0.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(
                            color: Colors.black,
                            //fontSize: 16.0,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor:  Color(0xFFF4F4F4),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          )
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 2.0),
                  PopupMenuButton<String>(
                    icon: Icon(
                      selectedFilter == 'bookmark' ? Icons.filter_alt : Icons.filter_alt_outlined,
                      color: selectedFilter == 'bookmark' ? Colors.black : Colors.black,
                    ),
                    onSelected: (value) {
                      setState(() {
                        selectedFilter = value;
                        showFavoritesOnly = selectedFilter == 'bookmark';
                      });
                    },
                    itemBuilder: (context){
                      return[
                      PopupMenuItem(
                        value: 'all',
                        child: Row(
                          children: [
                            if (selectedFilter == 'all')
                              const Icon(Icons.check, size: 20, color: Colors.black), // チェックマーク
                            const SizedBox(width: 8.0),
                            const Text('All Data'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'bookmark',
                        child: Row(
                          children: [
                            if (selectedFilter == 'bookmark')
                              const Icon(Icons.check, size: 20, color: Colors.black), // チェックマーク
                            const SizedBox(width: 8.0),
                            const Text('Bookmark'),
                          ],
                        ),
                      ),
                    ];
                      },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                // 추출 카테고리 정의
                children: ['All', '어깨', '가슴', '등', '팔', '하체', '복근', '유산소']
                    .map((category) {
                      //카테고리 선택 여부 확인
                      bool isSelected = selectedBodyPart == category || (category == 'All' && selectedBodyPart == null);
                  return Row(
                    children: [
                      // 'All' 버튼의 왼쪽 SizedBox 추가
                      if (category == 'All') const SizedBox(width: 20.0),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 4.0, vertical: 14.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            isSelected ? Colors.blue : Colors.white70,
                            minimumSize: const Size(65, 30),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedBodyPart =
                              (category == 'All') ? null : category;
                            });
                          },
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 16.0, // 글자 크기를 설정함
                              color: isSelected ? Colors.white : Colors.black,
                              fontFamily: 'Roboto', // 폰트 설정함
                            ),
                          ),
                        ), //카테고리 버튼 디자인
                      ),
                      // '유산소' 버튼의 오른쪽 SizedBox 추가
                      if (category == '유산소') const SizedBox(width: 20.0),
                    ],
                  );
                }).toList(),
              ),
            ), //카테고리 buttom
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 0.0,
                  bottom: 20.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: filteredCategory.isNotEmpty
                    ? ListView.builder(
                  itemCount: filteredCategory.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredCategory[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2), // 그림자의 빛깔
                            offset: const Offset(0, 1.5), // 그림자위치(오른쪽 0px, 아래 1.5px)
                            blurRadius: 2.0, // 흐림의 반지름
                            spreadRadius: 0, // 그림자의 확대
                          ),
                        ],
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // 운동명(타이틀)과 영어명을 세로로 늘어놓다
                                  Flexible(
                                    flex: 0,
                                    child: Text(
                                      exercise['name'],
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      exercise['englishName'],
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // 난이도와 운동 부위를 세로로 나열합니다
                                  Text(
                                    '${exercise['difficulty']}  | ${exercise['effectiveBody']}',
                                    style: const TextStyle(fontSize: 14.0, color: Colors.black),
                                  ),
                                ],
                              ),
                              ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      favoriteService.toggleFavorite(exercise);
                                    });
                                  },
                                  icon: Icon(
                                    favoriteService.isFavorite(exercise)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: favoriteService.isFavorite(exercise)
                                        ? Colors.yellow
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            ),
                          ],
                        ),
                        // onTap 부분 수정
                        onTap: () {
                          if (exercise['name'] == '대게먹고싶다') {
                            // 프로바이더를 통해 게 애니메이션을 표시
                            Provider.of<CrabAnimationProvider>(context, listen: false).showCrab();

                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => _ExerciseDetailPage(exercise: exercise),
                                fullscreenDialog: true,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                )
                    : const Center(
                  child: Text(
                    '해당 데이터가 없습니다.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            )
          ],
        ),
    );
  }
}

// ExerciseDetailPage는 선택된 운동의 상세 정보를 표시하는 페이지이다
class _ExerciseDetailPage extends StatelessWidget {
  final Map<String, dynamic> exercise; // 상세 정보를 표시할 운동 데이터

  _ExerciseDetailPage({required this.exercise}); // 생성자에서 운동 데이터를 필수로 받음

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '실천 방법',
          style: TextStyle(
            fontFamily: 'Roboto', // 폰트 적용함
            fontSize: 28.0,
            fontWeight: FontWeight.w900, // 폰트 두께 설정함
            color: Colors.black, // 폰트 색상 설정함
          ),
        ),
        backgroundColor: Colors.white, // 앱바 배경색을 흰색으로 설정함
        iconTheme: const IconThemeData(color: Colors.black), // 앱바 아이콘 색상을 검은색으로 설정함
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼을 누르면 이전 화면으로 돌아감
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 아이콘을 검은색으로 설정함
        ),
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFEFEFEF),
            width: 1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // 전체 패딩 설정함
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${exercise['name']}',
                    style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('(${exercise['englishName']})',
                    style: const TextStyle(fontSize: 16.0, color: Color(0xFF666666),),
                  ),
                ],
              ),
                ],
              ),
              const SizedBox(height: 24),
              // 기준 정보 설정
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDEDFE0)),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('난이도',style: TextStyle(fontSize: 16.0)),
                        const SizedBox(width: 4.0),
                        //아이콘을 클릭하면 표시
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('난이도',textAlign: TextAlign.center),
                                  backgroundColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(21.0),
                                  content: const Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Low Level',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                                      Text('간단한 동작, 적은 무게나 낮은 강도, 초보자용 운동.',style: TextStyle(fontSize: 16.0)),
                                      SizedBox(width: 12.0),
                                      Text('Medium Level',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                                      Text('기본적인 동작, 적당한 무게나 근력 요구, 다소 어려운 운동.',style: TextStyle(fontSize: 16.0)),
                                      SizedBox(width: 12.0),
                                      Text('High Level',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                                      Text('복잡한 동작, 높은 무게나 기술 요구, 근육 강도가 큰 운동.',style: TextStyle(fontSize: 16.0)),
                                    ],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('닫다',style: TextStyle(color: Colors.blue),),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              size: 20.0,
                              color: Color(0xFF8B8B8B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 42.0),
                        Text(': ${exercise['difficulty']}',style: const TextStyle(fontSize: 16.0)),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('운동 부위',style: TextStyle(fontSize: 16.0)),
                        const SizedBox(width: 50.0),
                        Text(': ${exercise['effectiveBody']}',style: const TextStyle(fontSize: 16.0)),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('소비 칼로리',style: TextStyle(fontSize: 16.0)),
                        const SizedBox(width: 4.0),
                        //아이콘을 클릭하면 표시
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(21.0),
                                  title: Text('소비 칼로리'),
                                  content: const Text('소비 칼로리는 30분간 운동을 했을 때의 일반적인 평균값으로, 운동 강도, 체중, 운동 방식(세트와 반복 횟수) 등에 따라 달라지며, 개인의 체력 수준과 운동 방식에 따라 차이가 있을 수 있습니다.',
                                  style: TextStyle(fontSize: 16.0),),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('닫다',style: TextStyle(color: Colors.blue),),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              size: 20.0,
                              color: Color(0xFF8B8B8B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        const Text(': 250-350 kcal',style: TextStyle(fontSize: 16.0)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // 사진
              Center(
                child: Image.asset('assets/images/${exercise['imageUrl']}'),
              ),
              const SizedBox(height: 30),
              // 3colum
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("준비", style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...exercise['preparation'].map<Widget>((prep) => Text("• $prep",style: const TextStyle(fontSize: 16.0))).toList(),

                  const SizedBox(height: 30),

                  const Text("실행 방법", style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...exercise['steps'].map<Widget>((step) => Text("• $step",style: const TextStyle(fontSize: 16.0))).toList(),

                  const SizedBox(height: 30),

                  const Text("중요한 포인트", style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...exercise['keyPoints'].map<Widget>((point) => Text("• $point",style: const TextStyle(fontSize: 16.0))).toList(),

                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
