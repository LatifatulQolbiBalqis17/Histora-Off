import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'country_detail.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.initialContinent = 'Semua'});
  final String initialContinent;
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late String continent = widget.initialContinent;
  String q = '';
  bool asc = true;
  List<Country> filter(List<Country> all) {
    final out = all
        .where(
          (x) =>
              (continent == 'Semua' || x.continent == continent) &&
              (x.name.toLowerCase().contains(q.toLowerCase()) ||
                  x.capital.toLowerCase().contains(q.toLowerCase())),
        )
        .toList();
    out.sort(
      (a, b) => asc ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
    );
    return out;
  }

  @override
  Widget build(BuildContext c) {
    final s = c.watch<AppState>();
    final data = filter(s.countries);
    return Material(
      type: MaterialType.transparency,
      child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari negara atau ibu kota',
              suffixIcon: q.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => setState(() => q = ''),
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children:
                [
                      'Semua',
                      'Asia',
                      'Eropa',
                      'Afrika',
                      'Amerika Utara',
                      'Amerika Selatan',
                      'Oseania',
                      'Antartika',
                    ]
                    .map(
                      (x) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(x),
                          selected: continent == x,
                          onSelected: (_) => setState(() => continent = x),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
          child: Row(
            children: [
              Text(
                '${data.length} negara',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                tooltip: asc ? 'Urut Z–A' : 'Urut A–Z',
                onPressed: () => setState(() => asc = !asc),
                icon: Icon(asc ? Icons.sort_by_alpha : Icons.swap_vert),
              ),
            ],
          ),
        ),
        Expanded(
          child: data.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off,
                  title: 'Negara tidak ditemukan',
                  message: 'Coba periksa ejaan atau reset filter.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: data.length,
                  itemBuilder: (_, i) => CountryCard(country: data[i]),
                ),
        ),
      ],
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({
    super.key,
    this.initialContinent = 'Semua',
    this.title = 'Pencarian',
  });
  final String initialContinent;
  final String title;
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ExploreScreen(initialContinent: initialContinent),
  );
}

class CountryCard extends StatelessWidget {
  const CountryCard({super.key, required this.country});
  final Country country;
  @override
  Widget build(BuildContext c) {
    final s = c.watch<AppState>();
    final fav = s.favorites.contains(country.id);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          c,
          MaterialPageRoute(builder: (_) => CountryDetail(country: country)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CountryFlag(
                imagePath: country.flagImage,
                emoji: country.flagEmoji,
                width: 52,
                height: 42,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(c).textTheme.titleLarge,
                    ),
                    Text(
                      '${country.capital} • ${country.continent}',
                      style: TextStyle(
                        color: Theme.of(c).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: fav ? 'Hapus favorit' : 'Tambah favorit',
                onPressed: () => s.toggleFavorite(country.id),
                icon: Icon(
                  fav ? Icons.favorite : Icons.favorite_border,
                  color: fav ? Theme.of(c).colorScheme.error : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
