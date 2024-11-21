import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<Map<String, dynamic>>> loadJsonData(String fileName) async {
  // 특정 파일 이름의 JSON 파일 읽기
  String jsonString = await rootBundle.loadString('assets/food_data_by_category/$fileName.json');
  return List<Map<String, dynamic>>.from(json.decode(jsonString));
}

//이 함수는 JSON 데이터를 읽어서 List<Map<String, dynamic>> 형태로 반환