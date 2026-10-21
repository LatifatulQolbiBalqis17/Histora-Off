import 'dart:convert';
import 'dart:io';

void main() {
  final countries =
      jsonDecode(File('assets/data/countries.json').readAsStringSync()) as List;
  final questions =
      jsonDecode(File('assets/data/questions.json').readAsStringSync()) as List;
  final ids = countries.map((e) => e['id']).toSet();
  final errors = <String>[];
  for (final q in questions) {
    if (!ids.contains(q['countryId']))
      errors.add("${q['id']}: countryId tidak ditemukan");
    final opts = q['options'] as List;
    if (opts.length != 4) errors.add("${q['id']}: opsi harus 4");
    if (!opts.contains(q['answer']))
      errors.add("${q['id']}: jawaban tidak ada di opsi");
  }
  if (errors.isNotEmpty) {
    stderr.writeln(errors.join('\n'));
    exitCode = 1;
  } else {
    stdout.writeln(
      'Valid: ${countries.length} negara, ${questions.length} soal.',
    );
  }
}
