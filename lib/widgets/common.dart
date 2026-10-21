import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext c) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: compact ? 34 : 44,
        height: compact ? 34 : 44,
        decoration: BoxDecoration(
          color: HistoraColors.moss,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.public, color: HistoraColors.bronze),
      ),
      const SizedBox(width: 10),
      Text(
        'HISTORA',
        style: Theme.of(c).textTheme.titleLarge?.copyWith(
          letterSpacing: 2,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
    child: Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(c).textTheme.titleLarge)),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

class AssetPicture extends StatelessWidget {
  const AssetPicture(
    this.path, {
    super.key,
    this.height = 170,
    this.icon = Icons.landscape_outlined,
  });
  final String path;
  final double height;
  final IconData icon;
  @override
  Widget build(BuildContext c) {
    if (path.isEmpty) return _fallback(c);
    return Image.asset(
      path,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(c),
    );
  }

  Widget _fallback(BuildContext c) => Container(
    height: height,
    width: double.infinity,
    color: Theme.of(c).colorScheme.primary.withValues(alpha: .12),
    alignment: Alignment.center,
    child: Icon(icon, size: 48, color: Theme.of(c).colorScheme.primary),
  );
}

class CountryFlag extends StatelessWidget {
  const CountryFlag({
    super.key,
    required this.imagePath,
    required this.emoji,
    this.width = 52,
    this.height = 38,
  });

  final String imagePath;
  final String emoji;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(emoji.isEmpty ? '🌍' : emoji, style: TextStyle(fontSize: height * .72)),
    );
    return SizedBox(
      width: width,
      height: height,
      child: imagePath.isEmpty
          ? fallback
          : ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => fallback,
              ),
            ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext c) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: HistoraColors.accentOn(c)),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(c).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant),
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}
