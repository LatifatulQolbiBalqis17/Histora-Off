import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'quiz_screens.dart';

class CountryDetail extends StatefulWidget {
  const CountryDetail({super.key, required this.country});
  final Country country;
  @override
  State<CountryDetail> createState() => _CountryDetailState();
}

class _CountryDetailState extends State<CountryDetail>
    with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(length: 6, vsync: this);

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final country = widget.country;
    final state = context.watch<AppState>();
    final favorite = state.favorites.contains(country.id);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            titleSpacing: 0,
            title: Row(
              children: [
                CountryFlag(
                  imagePath: country.flagImage,
                  emoji: country.flagEmoji,
                  width: 38,
                  height: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    country.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => state.toggleFavorite(country.id),
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
                tooltip: 'Favorit',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AssetPicture(country.heroImage, height: 250),
                  // Kerudung atas & bawah: judul, ikon, dan tab tetap terbaca
                  // di atas foto hero apa pun.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.surface.withValues(alpha: .96),
                          Theme.of(context).colorScheme.surface.withValues(alpha: .78),
                          Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                          Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                          Theme.of(context).colorScheme.surface.withValues(alpha: .88),
                          Theme.of(context).colorScheme.surface.withValues(alpha: .97),
                        ],
                        stops: const [0, .26, .42, .70, .84, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: tabs,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'History'),
                Tab(text: 'Tempat'),
                Tab(text: 'Budaya'),
                Tab(text: 'Kuliner'),
                Tab(text: 'Fakta'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: tabs,
          children: [
            _Overview(country),
            _History(country),
            _Places(country),
            _Culture(country),
            _Foods(country),
            _Facts(country),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizRulesScreen(
                  category: 'Gabungan',
                  countryId: country.id,
                ),
              ),
            ),
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('Uji Pengetahuanmu'),
          ),
        ),
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad(this.child);
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(18), children: [child]);
}

class _Overview extends StatelessWidget {
  const _Overview(this.country);
  final Country country;
  @override
  Widget build(BuildContext context) => _Pad(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(country.overview, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.55,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _Info('Ibu kota', country.capital),
            _Info('Benua', country.continent),
            _Info('Populasi', country.population),
            _Info('Luas', country.area),
            _Info('Bahasa', country.language),
            _Info('Mata uang', country.currency),
            _Info('Zona waktu', country.timezone),
            _Info('Nama lokal', country.localName),
          ],
        ),
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

class _History extends StatelessWidget {
  const _History(this.country);
  final Country country;
  @override
  Widget build(BuildContext context) => country.history.isEmpty
      ? const _MissingContent(icon: Icons.history_edu, label: 'Sejarah')
      : _Pad(
    Column(
      children: country.history
          .map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text(
                  item.year.length > 4 ? item.year.substring(0, 4) : item.year,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              title: Text(item.title),
              subtitle: Text(item.description),
            ),
          )
          .toList(),
    ),
  );
}

class _Places extends StatelessWidget {
  const _Places(this.country);
  final Country country;
  @override
  Widget build(BuildContext context) => country.places.isEmpty
      ? const _MissingContent(icon: Icons.landscape_outlined, label: 'Tempat')
      : _Pad(
    Column(
      children: country.places
          .map(
            (place) => Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AssetPicture(place.image),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(place.city),
                        const SizedBox(height: 6),
                        Text(place.description),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _Culture extends StatelessWidget {
  const _Culture(this.country);
  final Country country;
  @override
  Widget build(BuildContext context) => country.culture.isEmpty
      ? const _MissingContent(icon: Icons.auto_stories_outlined, label: 'Budaya')
      : _Pad(
    Column(
      children: country.culture
          .map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.auto_stories_outlined),
                title: Text(item.title),
                subtitle: Text('${item.aspect}\n${item.description}'),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _Foods extends StatelessWidget {
  const _Foods(this.country);
  final Country country;
  @override
  Widget build(BuildContext context) => country.foods.isEmpty
      ? const _MissingContent(icon: Icons.restaurant_outlined, label: 'Makanan')
      : _Pad(
    Column(
      children: country.foods
          .map(
            (food) => Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AssetPicture(food.image, icon: Icons.restaurant),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('Bahan utama: ${food.ingredients}'),
                        const SizedBox(height: 6),
                        Text(food.description),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _Facts extends StatefulWidget {
  const _Facts(this.country);
  final Country country;
  @override
  State<_Facts> createState() => _FactsState();
}

class _FactsState extends State<_Facts> {
  int pick = 0;
  @override
  Widget build(BuildContext context) => _Pad(
    Column(
      children: [
        ...widget.country.facts.indexed.map(
          (entry) => Card(
            color: entry.$1 == pick
                ? Theme.of(context).colorScheme.secondaryContainer
                : null,
            child: ListTile(
              leading: CircleAvatar(child: Text('${entry.$1 + 1}')),
              title: Text(entry.$2),
              trailing: IconButton(
                onPressed: () => Share.share('${entry.$2}\n— HISTORA'),
                icon: const Icon(Icons.share_outlined),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: widget.country.facts.isEmpty
              ? null
              : () => setState(
                  () => pick = Random().nextInt(widget.country.facts.length),
                ),
          icon: const Icon(Icons.shuffle),
          label: const Text('Fakta Lain'),
        ),
      ],
    ),
  );
}

class _MissingContent extends StatelessWidget {
  const _MissingContent({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: icon,
    title: '$label belum diisi',
    message: 'Tambahkan datanya di assets/data/countries.json dan gambarnya di folder assets/images.',
  );
}
