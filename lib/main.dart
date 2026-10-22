import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/local_repository.dart';
import 'state/app_state.dart';
import 'screens/onboarding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(LocalRepository())..load(),
      child: const HistoraApp(),
    ),
  );
}

class HistoraApp extends StatelessWidget {
  const HistoraApp({super.key});
  @override
  Widget build(BuildContext c) {
    final s = c.watch<AppState>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HISTORA',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: s.dark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/histora_earth_bg.jpg', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // Tema terang: kerudung putih kebiruan agar teks navy terbaca
                // di atas foto bumi yang gelap. Tema gelap: kerudung navy lebih
                // pekat supaya teks putih tetap terbaca di area foto yang terang.
                colors: s.dark
                    ? const [Color(0xC4041827), Color(0xAA041827)]
                        : const [Color(0x73EAF4F8), Color(0x66DCEBF1)],
              ),
            ),
          ),
          if (child != null) child,
        ],
      ),
      home: s.ready
          ? const SplashScreen()
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
