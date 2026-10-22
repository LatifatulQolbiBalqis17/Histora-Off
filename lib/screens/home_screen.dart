import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'country_detail.dart';
import 'explore_screen.dart';
import 'quiz_screens.dart';
import '../data/places_index.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final featured = state.countries.isEmpty
        ? null
        : state.countries[DateTime.now().day % state.countries.length];
    final best = state.history.isEmpty
        ? 0
        : state.history
              .map((item) => item.score)
              .reduce((a, b) => a > b ? a : b);
    return Stack(
      fit: StackFit.expand,
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: HistoraColors.forest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SELAMAT DATANG',
                style: TextStyle(
                  color: HistoraColors.bronze,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jelajahi cerita\ndari seluruh dunia.',
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(color: HistoraColors.pearl),
              ),
              const SizedBox(height: 18),
              TextField(
                readOnly: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cari negara atau ibu kota…',
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Jelajahi Benua'),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
                [
                      'Asia',
                      'Eropa',
                      'Afrika',
                      'Amerika Utara',
                      'Amerika Selatan',
                      'Oseania',
                      'Antartika',
                    ]
                    .map(
                      (name) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(name),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchScreen(
                                initialContinent: name,
                                title: name,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        if (featured != null) ...[
          const SectionTitle('Negara Sorotan'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CountryDetail(country: featured),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
  builder: (context) {
    final photo = PlaceIndex.photoFor(featured.id);
    return AssetPicture(
      photo ?? featured.heroImage,
      height: 180,
    );
  },
),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CountryFlag(
                          imagePath: featured.flagImage,
                          emoji: featured.flagEmoji,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                featured.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                               Text(
                                 featured.facts.isEmpty
                                     ? '${featured.capital} • ${featured.continent}'
                                     : featured.facts.first,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SectionTitle('Belajar & Bermain'),
        Row(
          children: [
            Expanded(
              child: _Metric(
                icon: Icons.public,
                value: '7',
                label: 'Benua',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                icon: Icons.emoji_events_outlined,
                value: '$best',
                label: 'Skor terbaik',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                icon: Icons.favorite_border,
                value: '${state.favorites.length}',
                label: 'Favorit',
              ),
            ),
          ],
        ),
        const SectionTitle('Riwayat Terakhir'),
        if (state.history.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Belum ada riwayat. Coba kuis pertamamu!'),
            ),
          )
        else
          ...state.history
              .take(3)
              .map(
                (record) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${record.score}')),
                    title: Text(record.category),
                    subtitle: Text('${record.correct}/${record.total} benar'),
                    trailing: Text(record.date.substring(0, 10)),
                  ),
                ),
              ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QuizCategoriesScreen()),
          ),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Main Kuis'),
        ),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value, label;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: HistoraColors.accentOn(context)),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
