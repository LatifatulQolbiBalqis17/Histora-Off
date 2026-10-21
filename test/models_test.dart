import 'package:flutter_test/flutter_test.dart';
import 'package:histora/data/models.dart';

void main() {
  test('parses an offline quiz question', () {
    final q = QuizQuestion.fromJson({
      'id': '1',
      'category': 'Ibu Kota',
      'countryId': 'id',
      'text': 'Ibu kota?',
      'options': ['Jakarta', 'Bandung', 'Medan', 'Surabaya'],
      'answer': 'Jakarta',
      'explanation': 'Benar',
    });
    expect(q.options.length, 4);
    expect(q.answer, 'Jakarta');
  });
}
