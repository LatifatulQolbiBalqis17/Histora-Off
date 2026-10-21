import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_repository.dart';
import '../data/models.dart';

class AppState extends ChangeNotifier {
  AppState(this.repo);
  final LocalRepository repo;
  List<Country> countries = [];
  List<QuizQuestion> questions = [];
  Set<String> favorites = {};
  List<QuizRecord> history = [];
  bool ready = false, dark = false, onboardingDone = false;
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    dark = p.getBool('dark') ?? false;
    onboardingDone = p.getBool('onboarding') ?? false;
    countries = await repo.countries();
    questions = await repo.questions();
    favorites = await repo.favorites();
    history = await repo.history();
    ready = true;
    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    onboardingDone = true;
    (await SharedPreferences.getInstance()).setBool('onboarding', true);
    notifyListeners();
  }

  Future<void> setDark(bool v) async {
    dark = v;
    (await SharedPreferences.getInstance()).setBool('dark', v);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    await repo.toggleFavorite(id);
    favorites = await repo.favorites();
    notifyListeners();
  }

  Future<void> saveQuiz(QuizRecord r) async {
    await repo.saveQuiz(r);
    history = await repo.history();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await repo.clearHistory();
    history = [];
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    await repo.clearFavorites();
    favorites = {};
    notifyListeners();
  }
}
