import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  Set<String> favoriteExerciseNames = {};

  late SharedPreferences _prefs;

  Future<void> init() async {
      _prefs = await SharedPreferences.getInstance();
      final storedData = _prefs.getStringList('favoriteExercises');

      if (storedData != null) {
        favoriteExerciseNames = storedData.toSet();
      }
  }

  void toggleFavorite(Map<String, dynamic> exercise) {
    final exerciseName = exercise['name'].toString();
    if (favoriteExerciseNames.contains(exerciseName)) {
      favoriteExerciseNames.remove(exerciseName);
    } else {
      favoriteExerciseNames.add(exerciseName);
    }
    _saveFavorites();
  }

  bool isFavorite(Map<String, dynamic> exercise) {
    final exerciseName = exercise['name'].toString();
    return favoriteExerciseNames.contains(exerciseName);
  }

  void _saveFavorites() async {
    await _prefs.setStringList('favoriteExercises', favoriteExerciseNames.toList());
  }
}
