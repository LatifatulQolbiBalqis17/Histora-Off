import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'country_detail.dart';
import '../data/flag_index.dart';
import '../data/places_index.dart';
const cats = [
  ('Bendera', Icons.flag_outlined, 'Kenali negara dari benderanya.'),
  ('Ibu Kota', Icons.location_city_outlined, 'Pilih ibu kota yang tepat.'),
  ('Deskripsi', Icons.menu_book_outlined, 'Tebak negara dari petunjuk.'),
  (
    'Tempat Terkenal',
    Icons.account_balance_outlined,
    'Kenali negara dari landmark.',
  ),
  ('Gabungan', Icons.shuffle, 'Campuran seluruh kategori.'),
];

const catImages = {
  'Bendera': 'assets/images/quiz/bendera.jpg',
  'Ibu Kota': 'assets/images/quiz/ibukota.jpg',
  'Deskripsi': 'assets/images/quiz/deskripsi.jpg',
  'Tempat Terkenal': 'assets/images/quiz/tempat.jpg',
  'Gabungan': 'assets/images/quiz/gabungan.jpg',
};

class _CatPhoto extends StatelessWidget {
  const _CatPhoto({required this.path, required this.icon});
  final String? path;
  final IconData icon;

  @override
  Widget build(BuildContext c) {
    final fallback = CircleAvatar(
      radius: 26,
      backgroundColor: Theme.of(c).colorScheme.primary,
      child: Icon(icon, color: Theme.of(c).colorScheme.secondary),
    );
    if (path == null) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        path!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
class QuizCategoriesScreen extends StatelessWidget {
  const QuizCategoriesScreen({super.key});
  @override
  Widget build(BuildContext c) {
    final s = c.watch<AppState>();
    return Material(
      type: MaterialType.transparency,
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Kuis Negara Dunia', style: Theme.of(c).textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text(
          'Soal acak, tiga nyawa, dan waktu sepuluh menit.',
          style: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        ...cats.map((x) {
          final scores = s.history
              .where((r) => r.category == x.$1)
              .map((r) => r.score);
          final best = scores.isEmpty ? 0 : scores.reduce(max);
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: _CatPhoto(path: catImages[x.$1], icon: x.$2),
              title: Text(x.$1, style: Theme.of(c).textTheme.titleLarge),
              subtitle: Text('${x.$3}\nSkor terbaik: $best'),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => Navigator.push(
                c,
                MaterialPageRoute(
                  builder: (_) => QuizRulesScreen(category: x.$1),
                ),
              ),
            ),
          );
        }),
        const SectionTitle('Riwayat'),
        if (s.history.isEmpty)
          const Text('Belum ada kuis yang diselesaikan.')
        else
          ...s.history
              .take(8)
              .map(
                (r) => ListTile(
                  leading: CircleAvatar(child: Text('${r.score}')),
                  title: Text(r.category),
                  subtitle: Text(
                    '${r.correct}/${r.total} benar • ${r.seconds} detik',
                  ),
                  trailing: Text(r.date.substring(5, 10)),
                ),
              ),
      ],
      ),
    );
  }
}

class QuizRulesScreen extends StatelessWidget {
  const QuizRulesScreen({super.key, required this.category, this.countryId});
  final String category;
  final String? countryId;
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text(category)),
    body: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(
            Icons.quiz_outlined,
            size: 90,
            color: HistoraColors.accentOn(c),
          ),
          const SizedBox(height: 24),
          Text(
            'Siap menguji pengetahuanmu?',
            style: Theme.of(c).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const _Rule(Icons.format_list_numbered, 'Maksimal 50 soal per sesi'),
          const _Rule(Icons.timer_outlined, 'Batas waktu 10 menit'),
          const _Rule(
            Icons.favorite_outline,
            'Tiga nyawa sebelum permainan berakhir',
          ),
          const _Rule(Icons.shuffle, 'Urutan soal dan jawaban selalu diacak'),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacement(
              c,
              MaterialPageRoute(
                builder: (_) =>
                    QuizPlayScreen(category: category, countryId: countryId),
              ),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Mulai'),
          ),
        ],
      ),
    ),
  );
}

class _Rule extends StatelessWidget {
  const _Rule(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(c).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key, required this.category, this.countryId});
  final String category;
  final String? countryId;
  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  List<QuizQuestion> qs = [];
  final answers = <String, String>{};
  int i = 0, lives = 3, seconds = 600;
  Timer? timer;
  String? selected;
  bool locked = false, finishing = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setup());
  }

  void setup() {
    final all =
        context
            .read<AppState>()
            .questions
            .where(
              (q) =>
                  (widget.category == 'Gabungan' ||
                      q.category == widget.category) &&
                  (widget.countryId == null || q.countryId == widget.countryId),
            )
            .toList()
          ..shuffle();
    if (all.isEmpty && widget.countryId != null) {
      all.addAll(
        context.read<AppState>().questions.where(
          (q) => widget.category == 'Gabungan' || q.category == widget.category,
        ),
      );
    }
    qs = all.take(50).map((q) {
      final options = [...q.options]..shuffle();
      return QuizQuestion(
        id: q.id,
        category: q.category,
        countryId: q.countryId,
        text: q.text,
        options: options,
        answer: q.answer,
        explanation: q.explanation,
        image: q.image,
      );
    }).toList();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds <= 1) {
        finish();
      } else if (mounted)
        setState(() => seconds--);
    });
    setState(() {});
  }

  void answer(String a) {
    if (locked) return;
    setState(() {
      selected = a;
      locked = true;
      answers[qs[i].id] = a;
      if (a != qs[i].answer) lives--;
    });
    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      if (lives == 0 || i == qs.length - 1) {
        finish();
      } else {
        setState(() {
          i++;
          selected = null;
          locked = false;
        });
      }
    });
  }

  Future<void> finish() async {
    if (finishing || qs.isEmpty) return;
    finishing = true;
    timer?.cancel();
    final correct = qs.where((q) => answers[q.id] == q.answer).length;
    final score = ((correct / qs.length) * 100).round();
    final r = QuizRecord(
      category: widget.category,
      score: score,
      correct: correct,
      total: qs.length,
      seconds: 600 - seconds,
      date: DateTime.now().toIso8601String(),
    );
    await context.read<AppState>().saveQuiz(r);
    if (mounted)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            record: r,
            questions: qs,
            answers: answers,
            category: widget.category,
          ),
        ),
      );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    if (qs.isEmpty)
      return const Scaffold(
        body: EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Soal belum tersedia',
          message: 'Tambahkan soal pada assets/data/questions.json.',
        ),
      );
    final q = qs[i];
    final m = (seconds ~/ 60).toString().padLeft(2, '0'),
        sec = (seconds % 60).toString().padLeft(2, '0');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: c,
          builder: (_) => AlertDialog(
            title: const Text('Keluar dari kuis?'),
            content: const Text('Sesi ini akan dibatalkan dan tidak disimpan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Lanjut Kuis'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Keluar'),
              ),
            ],
          ),
        );
        if (leave == true && c.mounted) Navigator.pop(c);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.category)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Chip(
                  avatar: const Icon(Icons.timer_outlined, size: 18),
                  label: Text('$m:$sec'),
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: Icon(
                    Icons.favorite,
                    size: 18,
                    color: HistoraColors.dangerOn(c),
                  ),
                  label: Text('$lives / 3'),
                ),
                const Spacer(),
                Text(
                  '${i + 1} / ${qs.length}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            LinearProgressIndicator(
              value: (i + 1) / qs.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 18),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                   if (q.image.isNotEmpty)
                    q.category == 'Bendera'
                        ? Container(
                            height: 190,
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: Theme.of(c)
                                .colorScheme
                                .primary
                                .withValues(alpha: .08),
                            child: Image.asset(
                              FlagIndex.resolve(q.image),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.flag_outlined,
                                size: 48,
                                color: Theme.of(c).colorScheme.primary,
                              ),
                            ),
                          )
                        : AssetPicture(q.image),
                                          if (q.image.isEmpty &&
                      q.category == 'Tempat Terkenal' &&
                      PlaceIndex.photoFor(q.countryId) != null)
                    AssetPicture(PlaceIndex.photoFor(q.countryId)!, height: 200),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SOAL ${i + 1}',
                          style: TextStyle(
                            color: HistoraColors.accentOn(c),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          q.text,
                          style: Theme.of(c).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...q.options.map((a) {
              final chosen = selected == a, correct = locked && a == q.answer;
              Color? color;
              if (correct)
                color = HistoraColors.success;
              else if (chosen)
                color = HistoraColors.danger;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: OutlinedButton(
                  onPressed: () => answer(a),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerLeft,
                    side: BorderSide(
                      color: color ?? Theme.of(c).colorScheme.outline,
                      width: chosen || correct ? 2 : 1,
                    ),
                    backgroundColor: color?.withValues(alpha: .10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    a,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }),
            if (locked)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  selected == q.answer
                      ? 'Benar! ${q.explanation}'
                      : 'Belum tepat. Jawaban: ${q.answer}. ${q.explanation}',
                  style: TextStyle(
                    color: selected == q.answer
                        ? HistoraColors.successOn(c)
                        : HistoraColors.dangerOn(c),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.record,
    required this.questions,
    required this.answers,
    required this.category,
  });
  final QuizRecord record;
  final List<QuizQuestion> questions;
  final Map<String, String> answers;
  final String category;

  @override
  Widget build(BuildContext context) {
    final predicate = record.score >= 85
        ? 'Sangat Baik'
        : record.score >= 70
        ? 'Baik'
        : record.score >= 55
        ? 'Cukup'
        : 'Perlu Belajar Lagi';
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Kuis')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 10,
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${record.score}',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(predicate, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  'Benar',
                  '${record.correct}',
                  HistoraColors.successOn(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Stat(
                  'Salah',
                  '${record.total - record.correct}',
                  HistoraColors.dangerOn(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Stat(
                  'Waktu',
                  '${record.seconds}s',
                  HistoraColors.accentOn(context),
                ),
              ),
            ],
          ),
          const SectionTitle('Pembahasan'),
          ...questions.indexed.map((entry) {
            final question = entry.$2;
            final correct = answers[question.id] == question.answer;
            return Card(
              child: ExpansionTile(
                leading: Icon(
                  correct ? Icons.check_circle : Icons.cancel,
                  color: correct
                      ? HistoraColors.successOn(context)
                      : HistoraColors.dangerOn(context),
                ),
                title: Text(
                  '${entry.$1 + 1}. ${question.text}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('Jawaban benar: ${question.answer}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(question.explanation),
                        const SizedBox(height: 8),
                        if (question.countryId.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              final country = context
                                  .read<AppState>()
                                  .countries
                                  .where(
                                    (item) => item.id == question.countryId,
                                  )
                                  .firstOrNull;
                              if (country != null)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CountryDetail(country: country),
                                  ),
                                );
                            },
                            child: const Text('Pelajari negara ini'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => QuizRulesScreen(category: category),
              ),
            ),
            icon: const Icon(Icons.replay),
            label: const Text('Ulangi Kuis'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali ke Daftar Kuis'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: color),
          ),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    ),
  );
}
