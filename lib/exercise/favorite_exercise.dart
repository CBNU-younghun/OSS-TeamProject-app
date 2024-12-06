import 'package:flutter/material.dart';

class FavoriteService extends ChangeNotifier {
  List<Map<String, dynamic>> _favoriteExercises = [];

  List<Map<String, dynamic>> get favoriteExercises => _favoriteExercises;

  //Bookmark에 추가되어 있는지 확인
  bool isFavorite(Map<String, dynamic> exercise) {
    return _favoriteExercises.contains(exercise);
  }

  //Bookmark추가/삭제 토글함수
  void toggleFavorite(Map<String, dynamic> exercise) {
    if (_favoriteExercises.contains(exercise)) {
      _favoriteExercises.remove(exercise);
    } else {
      _favoriteExercises.add(exercise);
    }
    notifyListeners();
  }
}