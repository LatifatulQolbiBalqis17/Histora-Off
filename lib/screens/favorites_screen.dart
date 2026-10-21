import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'explore_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext c) {
    final s = c.watch<AppState>();
    final rows = s.countries.where((x) => s.favorites.contains(x.id)).toList();
    if (rows.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        title: 'Belum ada negara favorit',
        message: 'Simpan negara yang ingin kamu pelajari lagi.',
        action: ElevatedButton(
          onPressed: () => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
          child: const Text('Jelajahi Negara'),
        ),
      );
    }
    return Material(
      type: MaterialType.transparency,
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Koleksi Favorit', style: Theme.of(c).textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text('${rows.length} negara tersimpan di perangkat'),
        const SizedBox(height: 12),
        ...rows.map((x) => CountryCard(country: x)),
      ],
      ),
    );
  }
}
