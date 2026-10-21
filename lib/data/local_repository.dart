import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'models.dart';

class LocalRepository {
  Database? _db;
  List<Country>? _countries;
  List<QuizQuestion>? _questions;
  Future<Database> get database async => _db ??= await openHistoraDatabase(
    onCreate: (db) async {
      await db.execute(
        'CREATE TABLE favorites(country_id TEXT PRIMARY KEY, created_at TEXT NOT NULL)',
      );
      await db.execute(
        'CREATE TABLE quiz_history(id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT, score INTEGER, correct_count INTEGER, total INTEGER, seconds INTEGER, date TEXT)',
      );
    },
  );

  Future<List<Country>> countries() async {
    if (_countries != null) return _countries!;
    final raw = await rootBundle.loadString('assets/data/countries.json');
    _countries = (jsonDecode(raw) as List)
        .map((e) => Country.fromJson(e))
        .toList();
    return _countries!;
  }

  Future<List<QuizQuestion>> questions() async {
    if (_questions != null) return _questions!;
    final raw = await rootBundle.loadString('assets/data/questions.json');
    _questions = (jsonDecode(raw) as List)
        .map((e) => QuizQuestion.fromJson(e))
        .toList();
    return _questions!;
  }

  Future<Set<String>> favorites() async => (await (await database).query(
    'favorites',
  )).map((e) => e['country_id'] as String).toSet();
  Future<void> toggleFavorite(String id) async {
    final db = await database;
    final found = await db.query(
      'favorites',
      where: 'country_id=?',
      whereArgs: [id],
    );
    if (found.isEmpty) {
      await db.insert('favorites', {
        'country_id': id,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await db.delete('favorites', where: 'country_id=?', whereArgs: [id]);
    }
  }

  Future<List<QuizRecord>> history() async =>
      (await (await database).query('quiz_history', orderBy: 'date DESC'))
          .map(
            (e) => QuizRecord(
              category: e['category'] as String,
              score: e['score'] as int,
              correct: e['correct_count'] as int,
              total: e['total'] as int,
              seconds: e['seconds'] as int,
              date: e['date'] as String,
            ),
          )
          .toList();
  Future<void> saveQuiz(QuizRecord r) async =>
      (await database).insert('quiz_history', {
        'category': r.category,
        'score': r.score,
        'correct_count': r.correct,
        'total': r.total,
        'seconds': r.seconds,
        'date': r.date,
      });
  Future<void> clearHistory() async => (await database).delete('quiz_history');
  Future<void> clearFavorites() async => (await database).delete('favorites');
}
