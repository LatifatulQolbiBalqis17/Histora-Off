import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<bool> ask(BuildContext context, String message) async =>
      (await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      )) ??
      false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: BrandMark()),
          const SizedBox(height: 28),
          Card(
            child: SwitchListTile(
              value: state.dark,
              onChanged: state.setDark,
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Tema gelap'),
              subtitle: const Text('Gunakan tampilan obsidian Histora'),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Hapus riwayat kuis'),
                  onTap: () async {
                    if (await ask(
                      context,
                      'Hapus seluruh hasil kuis dari perangkat?',
                    )) {
                      state.clearHistory();
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.heart_broken_outlined),
                  title: const Text('Hapus semua favorit'),
                  onTap: () async {
                    if (await ask(context, 'Hapus seluruh negara favorit?')) {
                      state.clearFavorites();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HISTORA Mobile',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Versi 1.0.0\nAplikasi pembelajaran sejarah dan eksplorasi negara dunia. Seluruh konten inti tersedia offline.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
