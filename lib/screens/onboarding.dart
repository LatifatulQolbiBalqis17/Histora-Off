import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';
import 'app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool ready = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => ready = true);
    });
  }

  Future<void> _start() async {
    final state = context.read<AppState>();
    if (!state.onboardingDone) await state.finishOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/histora_earth_bg.jpg', fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x9902182A), Color(0x1902182A), Color(0xB302182A)],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 34),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const _TravelMark(size: 116),
                const SizedBox(height: 18),
                Text(
                  'HISTORA',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(flex: 3),
                AnimatedOpacity(
                  opacity: ready ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(onPressed: _start, child: const Text('MULAI')),
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lightbulb, color: Color(0xFFE4BC32), size: 34),
                    SizedBox(width: 10),
                    Text(
                      'Eksplorasi Dunia\nAsah Pengetahuan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _TravelMark extends StatelessWidget {
  const _TravelMark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.public, color: Theme.of(context).colorScheme.secondary, size: size),
        Positioned(
          left: 0,
          top: 0,
          child: Transform.rotate(
            angle: -.55,
            child: Icon(Icons.flight, color: Theme.of(context).colorScheme.secondary, size: size * .42),
          ),
        ),
      ],
    ),
  );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int index = 0;
  final pages = const [
    (
      Icons.travel_explore,
      'Jelajahi Dunia',
      'Kenali negara, sejarah, budaya, landmark, dan kuliner dalam satu tempat.',
    ),
    (
      Icons.quiz_outlined,
      'Uji Pengetahuan',
      'Tantang dirimu melalui kuis offline yang berbeda setiap sesi.',
    ),
    (
      Icons.favorite_border,
      'Simpan Favorit',
      'Bangun koleksi negara pilihanmu dan buka kembali kapan pun.',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Material(
      type: MaterialType.transparency,
      child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Align(alignment: Alignment.centerLeft, child: BrandMark()),
            Expanded(
              child: PageView(
                controller: controller,
                onPageChanged: (value) => setState(() => index = value),
                children: pages
                    .map(
                      (page) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Icon(
                              page.$1,
                              size: 72,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            page.$2,
                            style: Theme.of(context).textTheme.headlineLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.$3,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            Row(
              children: [
                ...List.generate(
                  3,
                  (dot) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    width: dot == index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dot == index
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (index < 2) {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      await context.read<AppState>().finishOnboarding();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const AppShell()),
                        );
                      }
                    }
                  },
                  child: Text(index == 2 ? 'Mulai' : 'Lanjut'),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    ),
  );
}
