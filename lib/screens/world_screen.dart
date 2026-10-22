import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'country_detail.dart';
import '../data/flag_index.dart';
import '../data/places_index.dart';

// =========================================================
// HISTORA World — Globe 3D fotorealistik.
// Disamakan dengan globe di web Histora (globe.gl):
//  • tekstur Blue Marble + relief (bump) + lapisan awan berputar
//  • poligon negara (Natural Earth 110m) dengan garis batas putih tipis
//  • ketuk wilayah negara -> sorotan emas + kamera terbang + profil negara
//  • sudut pandang awal lat 10 / lng 110 dan rotasi otomatis pelan
// Semua aset dimuat dari bundle (offline).
// =========================================================

const double _initLat = 10;
const double _initLng = 110;
const double _autoRotateSpeed = .042; // rad/detik (setara autoRotateSpeed 0.4)
const double _cloudSpeed = .021; // rad/detik

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen>
    with SingleTickerProviderStateMixin {
  _GlobeAssets? assets;
  List<_GeoCountry> geo = const [];
  List<_Dot> dots = const [];
  late final AnimationController ticker;

  // Kamera: titik yang menghadap ke penonton (radian).
  double centerLng = _initLng * math.pi / 180;
  double centerLat = _initLat * math.pi / 180;
  double cloudOffset = 0;
  bool dragging = false;
  bool paused = false; // jeda rotasi otomatis saat profil negara terbuka
  int lastTick = 0;
  String? selectedKey;
  _Fly? fly;

  @override
  void initState() {
    super.initState();
    ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..addListener(_onTick)
      ..repeat(min: 0, max: 1, period: const Duration(seconds: 1));
    _loadAll();
  }

  void _onTick() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (lastTick != 0 && mounted) {
      final dt = math.min((now - lastTick) / 1000, .05);
      setState(() {
        cloudOffset = (cloudOffset + dt * _cloudSpeed) % (math.pi * 2);
        final f = fly;
        if (f != null) {
          final t = ((now - f.startMs) / f.durationMs).clamp(0.0, 1.0);
          final e = t < .5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
          centerLat = f.fromLat + (f.toLat - f.fromLat) * e;
          centerLng = f.fromLng + (f.toLng - f.fromLng) * e;
          if (t >= 1) fly = null;
        } else if (!dragging && !paused) {
          centerLng = (centerLng - dt * _autoRotateSpeed) % (math.pi * 2);
        }
      });
    }
    lastTick = now;
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        _loadImage('assets/images/globe/earth_blue_marble.jpg'),
        _loadImage('assets/images/globe/clouds.png'),
        rootBundle.loadString('assets/data/globe_countries.json'),
        rootBundle.loadString('assets/data/world_countries.json'),
      ]);
      final earth = results[0] as ui.Image;
      final clouds = results[1] as ui.Image;
      final loaded = (jsonDecode(results[2] as String) as List)
          .whereType<Map<String, dynamic>>()
          .map(_GeoCountry.fromJson)
          .toList(growable: false);
      final ids = loaded.map((c) => c.id).where((id) => id.isNotEmpty).toSet();
      final extra = (jsonDecode(results[3] as String) as List)
          .whereType<Map<String, dynamic>>()
          .where((j) => !ids.contains(j['id']))
          .map(_Dot.fromJson)
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        assets = _GlobeAssets(earth, clouds);
        geo = loaded;
        dots = extra;
      });
    } catch (_) {
      // Tanpa aset globe tetap tampil bola polos agar aplikasi tidak error.
    }
  }

  static Future<ui.Image> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void dispose() {
    ticker.dispose();
    assets?.dispose();
    super.dispose();
  }

  void _flyTo(double latDeg, double lngDeg, {int ms = 900}) {
    final toLat = latDeg * math.pi / 180;
    var toLng = lngDeg * math.pi / 180;
    // Ambil jalur terpendek untuk bujur.
    var diff = (toLng - centerLng) % (math.pi * 2);
    if (diff > math.pi) diff -= math.pi * 2;
    if (diff < -math.pi) diff += math.pi * 2;
    toLng = centerLng + diff;
    fly = _Fly(
      fromLat: centerLat,
      fromLng: centerLng,
      toLat: toLat.clamp(-1.25, 1.25).toDouble(),
      toLng: toLng,
      startMs: DateTime.now().millisecondsSinceEpoch,
      durationMs: ms,
    );
  }

  void _resetView() {
    paused = false;
    _flyTo(_initLat, _initLng, ms: 1200);
  }

  void _handleTap(Offset local, double diameter) {
    final size = Size.square(diameter);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = _globeRadius(size);
    final view = _View(centerLng, centerLat);

    // 1) Negara kecil tanpa poligon (titik emas).
    _Dot? hitDot;
    double best = 22;
    for (final dot in dots) {
      final p = view.project(dot.ux, dot.uy, dot.uz);
      if (p.z < .05) continue;
      final d = (Offset(center.dx + p.x * radius, center.dy - p.y * radius) -
              local)
          .distance;
      if (d < best) {
        best = d;
        hitDot = dot;
      }
    }
    if (hitDot != null) {
      _select('dot:${hitDot.id}', hitDot.lat, hitDot.lng, hitDot.id, hitDot.name);
      return;
    }

    // 2) Wilayah negara: ubah titik ketukan menjadi lintang/bujur.
    final nx = (local.dx - center.dx) / radius;
    final ny = -(local.dy - center.dy) / radius;
    final rho2 = nx * nx + ny * ny;
    if (rho2 > 1) return;
    final ll = view.unproject(nx, ny, math.sqrt(1 - rho2));
    for (final country in geo) {
      if (country.contains(ll.$1, ll.$2)) {
        _select('geo:${country.iso3}', country.lat, country.lng, country.id,
            country.name);
        return;
      }
    }
  }

  void _select(String key, double lat, double lng, String id, String name) {
    setState(() {
      selectedKey = key;
      paused = true;
    });
    _flyTo(lat, lng);
    _showPreview(id, name);
  }

  Future<void> _showPreview(String id, String fallbackName) async {
    Country? country;
    for (final c in context.read<AppState>().countries) {
      if (c.id == id && id.isNotEmpty) {
        country = c;
        break;
      }
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => _CountryPreview(
        country: country,
        fallbackName: fallbackName,
        onOpen: country == null
            ? null
            : () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CountryDetail(country: country!),
                  ),
                );
              },
      ),
    );
    if (!mounted) return;
    setState(() => selectedKey = null);
    _resetView();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      // Latar ruang angkasa gelap (seperti hero globe di web) agar teks terang
      // dan globe selalu terbaca di tema terang maupun gelap.
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xF2020E1B), Color(0xE0041827), Color(0xF0020E1B)],
          ),
        ),
      ),
      Material(
        type: MaterialType.transparency,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 104),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
  width: double.infinity,
 
),
                
                const SizedBox(height: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final diameter = math.min(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      return Center(
                        child: SizedBox.square(
                          dimension: diameter,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (_) => setState(() {
                              dragging = true;
                              fly = null;
                            }),
                            onPanUpdate: (details) {
                              final r = _globeRadius(Size.square(diameter));
                              setState(() {
                                centerLng =
                                    (centerLng - details.delta.dx / r) %
                                    (math.pi * 2);
                                centerLat = (centerLat + details.delta.dy / r)
                                    .clamp(-1.25, 1.25)
                                    .toDouble();
                              });
                            },
                            onPanEnd: (_) => setState(() => dragging = false),
                            onPanCancel: () =>
                                setState(() => dragging = false),
                            onTapUp: (details) =>
                                _handleTap(details.localPosition, diameter),
                            child: CustomPaint(
                              painter: _GlobePainter(
                                assets: assets,
                                geo: geo,
                                dots: dots,
                                centerLng: centerLng,
                                centerLat: centerLat,
                                cloudOffset: cloudOffset,
                                selectedKey: selectedKey,
                              ),
                              child: assets == null
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF7FE7F2),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.threesixty,
                        size: 18,
                        color: Color(0xFFFFD866),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Putar globe dan ketuk wilayah negara\nuntuk melihat profilnya.',
                        style: TextStyle(
                          color: const Color(0xFFFFD866),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .3,
                          shadows: const [
                            Shadow(
                              color: Color(0xAA02101E),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

double _globeRadius(Size size) => math.min(size.width, size.height) * .47;

// ---------------------------------------------------------
// Profil negara (setara modal "lp-cmodal" di web)
// ---------------------------------------------------------
class _CountryPreview extends StatelessWidget {
  const _CountryPreview({
    required this.country,
    required this.fallbackName,
    required this.onOpen,
  });

  final Country? country;
  final String fallbackName;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = country;
    final accent = HistoraColors.accentOn(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (c?.continent ?? 'Negara').toUpperCase(),
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (c != null) ...[
                  CountryFlag(
                    imagePath: c.flagImage,
                    emoji: c.flagEmoji,
                    width: 44,
                    height: 32,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    c?.name ?? fallbackName,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            if (c != null && c.capital.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  text: 'Ibu kota · ',
                  children: [
                    TextSpan(
                      text: c.capital,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            if (c != null) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
  PlaceIndex.photoFor(c.id) ?? c.heroImage,
  width: double.infinity,
  height: 150,
  fit: BoxFit.cover,
  errorBuilder: (_, __, ___) => Image.asset(
    FlagIndex.resolve(c.flagImage),
    width: double.infinity,
    height: 150,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => AssetPicture('', height: 150),
  ),
),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              c == null
                  ? 'Profil negara ini sedang disiapkan oleh tim Histora.'
                  : (c.overview.isEmpty
                        ? '${c.name} adalah salah satu negara di dunia.'
                        : c.overview),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            if (c != null && c.places.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Tempat Terkenal',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 6),
              ...PlaceIndex.itemsFor(c)
                  .take(2)
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text.rich(
                        TextSpan(
                          text: p.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                          children: [
                            if (p.description.isNotEmpty)
                              TextSpan(
                                text: ' — ${p.description}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
            ],
            if (onOpen != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Lebih Lanjut'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Data
// ---------------------------------------------------------
class _Fly {
  const _Fly({
    required this.fromLat,
    required this.fromLng,
    required this.toLat,
    required this.toLng,
    required this.startMs,
    required this.durationMs,
  });
  final double fromLat, fromLng, toLat, toLng;
  final int startMs, durationMs;
}

class _P3 {
  const _P3(this.x, this.y, this.z);
  final double x, y, z;
}

/// Rotasi kamera (ortografik): bujur & lintang titik yang menghadap penonton.
class _View {
  _View(double lng, double lat)
    : cosL = math.cos(lng),
      sinL = math.sin(lng),
      cosP = math.cos(lat),
      sinP = math.sin(lat);
  final double cosL, sinL, cosP, sinP;

  _P3 project(double ux, double uy, double uz) {
    final x = ux * cosL - uz * sinL;
    final z1 = ux * sinL + uz * cosL;
    return _P3(x, cosP * uy - sinP * z1, sinP * uy + cosP * z1);
  }

  /// (nx, ny, nz) di ruang layar -> (lintang°, bujur°).
  (double, double) unproject(double x, double y, double z) {
    final Y = cosP * y + sinP * z;
    final z1 = -sinP * y + cosP * z;
    final X = x * cosL + z1 * sinL;
    final Z = -x * sinL + z1 * cosL;
    return (
      math.asin(Y.clamp(-1.0, 1.0)) * 180 / math.pi,
      math.atan2(X, Z) * 180 / math.pi,
    );
  }
}

class _Ring {
  _Ring(List<List<double>> pts) {
    final n = pts.length;
    lng = Float32List(n);
    lat = Float32List(n);
    ux = Float32List(n);
    uy = Float32List(n);
    uz = Float32List(n);
    double minX = 999, maxX = -999, minY = 999, maxY = -999;
    for (var i = 0; i < n; i++) {
      final lo = pts[i][0], la = pts[i][1];
      lng[i] = lo;
      lat[i] = la;
      final phi = la * math.pi / 180, lam = lo * math.pi / 180;
      ux[i] = math.cos(phi) * math.sin(lam);
      uy[i] = math.sin(phi);
      uz[i] = math.cos(phi) * math.cos(lam);
      minX = math.min(minX, lo);
      maxX = math.max(maxX, lo);
      minY = math.min(minY, la);
      maxY = math.max(maxY, la);
    }
    minLng = minX;
    maxLng = maxX;
    minLat = minY;
    maxLat = maxY;
  }

  late final Float32List lng, lat, ux, uy, uz;
  late final double minLng, maxLng, minLat, maxLat;
  int get length => lng.length;

  bool contains(double la, double lo) {
    if (lo < minLng || lo > maxLng || la < minLat || la > maxLat) return false;
    var inside = false;
    for (var i = 0, j = length - 1; i < length; j = i++) {
      final xi = lng[i], yi = lat[i], xj = lng[j], yj = lat[j];
      if ((yi > la) != (yj > la) &&
          lo < (xj - xi) * (la - yi) / (yj - yi) + xi) {
        inside = !inside;
      }
    }
    return inside;
  }
}

class _GeoCountry {
  _GeoCountry({
    required this.iso3,
    required this.id,
    required this.name,
    required this.rings,
  }) {
    // Pusat kamera = titik tengah bounding box poligon terbesar.
    _Ring? biggest;
    double area = -1;
    for (final r in rings) {
      final a = (r.maxLng - r.minLng) * (r.maxLat - r.minLat);
      if (a > area) {
        area = a;
        biggest = r;
      }
    }
    lng = biggest == null ? 0 : (biggest.minLng + biggest.maxLng) / 2;
    lat = biggest == null ? 0 : (biggest.minLat + biggest.maxLat) / 2;
  }

  final String iso3, id, name;
  final List<_Ring> rings;
  late final double lat, lng;

  factory _GeoCountry.fromJson(Map<String, dynamic> json) {
    final rings = <_Ring>[];
    for (final poly in (json['polys'] as List)) {
      // Hanya cincin luar; lubang tidak dipakai (sama seperti kebutuhan klik).
      final outer = (poly as List).first as List;
      rings.add(
        _Ring(
          outer
              .map<List<double>>(
                (p) => [(p[0] as num).toDouble(), (p[1] as num).toDouble()],
              )
              .toList(),
        ),
      );
    }
    return _GeoCountry(
      iso3: json['iso3'] as String? ?? '',
      id: (json['iso2'] as String? ?? '').toLowerCase(),
      name: json['name'] as String? ?? '',
      rings: rings,
    );
  }

  bool contains(double la, double lo) {
    for (final r in rings) {
      if (r.contains(la, lo)) return true;
    }
    return false;
  }
}

/// Negara kecil yang terlalu kecil untuk poligon 110m (mis. Singapura, Malta).
class _Dot {
  _Dot({required this.id, required this.name, required this.lat, required this.lng}) {
    final phi = lat * math.pi / 180, lam = lng * math.pi / 180;
    ux = math.cos(phi) * math.sin(lam);
    uy = math.sin(phi);
    uz = math.cos(phi) * math.cos(lam);
  }
  final String id, name;
  final double lat, lng;
  late final double ux, uy, uz;

  factory _Dot.fromJson(Map<String, dynamic> json) => _Dot(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    lat: (json['lat'] as num?)?.toDouble() ?? 0,
    lng: (json['lng'] as num?)?.toDouble() ?? 0,
  );
}

// ---------------------------------------------------------
// Mesh bola bertekstur
// ---------------------------------------------------------
class _Sphere {
  static const latN = 72, lonN = 144;
  static const cols = lonN + 1;
  static final count = (latN + 1) * cols;

  static final Float32List ux = Float32List(count);
  static final Float32List uy = Float32List(count);
  static final Float32List uz = Float32List(count);
  static bool _ready = false;

  static void ensure() {
    if (_ready) return;
    _ready = true;
    for (var i = 0; i <= latN; i++) {
      final phi = (90 - i * 180 / latN) * math.pi / 180;
      for (var j = 0; j <= lonN; j++) {
        final lam = (-180 + j * 360 / lonN) * math.pi / 180;
        final k = i * cols + j;
        ux[k] = math.cos(phi) * math.sin(lam);
        uy[k] = math.sin(phi);
        uz[k] = math.cos(phi) * math.cos(lam);
      }
    }
  }

  static Float32List texCoords(int w, int h) {
    final t = Float32List(count * 2);
    for (var i = 0; i <= latN; i++) {
      for (var j = 0; j <= lonN; j++) {
        final k = i * cols + j;
        t[k * 2] = j / lonN * w;
        t[k * 2 + 1] = i / latN * h;
      }
    }
    return t;
  }
}

class _GlobeAssets {
  _GlobeAssets(this.earth, this.clouds) {
    _Sphere.ensure();
    earthTex = _Sphere.texCoords(earth.width, earth.height);
    cloudTex = _Sphere.texCoords(clouds.width, clouds.height);
    earthShader = ui.ImageShader(
      earth,
      TileMode.clamp,
      TileMode.clamp,
      Matrix4.identity().storage,
    );
    cloudShader = ui.ImageShader(
      clouds,
      TileMode.clamp,
      TileMode.clamp,
      Matrix4.identity().storage,
    );
  }

  final ui.Image earth, clouds;
  late final Float32List earthTex, cloudTex;
  late final ui.ImageShader earthShader, cloudShader;

  // Buffer kerja yang dipakai ulang tiap frame.
  final Float32List pos = Float32List(_Sphere.count * 2);
  final Float32List vz = Float32List(_Sphere.count);
  final Int32List col = Int32List(_Sphere.count);
  final Uint16List idx = Uint16List(_Sphere.latN * _Sphere.lonN * 6);

  void dispose() {
    earthShader.dispose();
    cloudShader.dispose();
    earth.dispose();
    clouds.dispose();
  }
}

// ---------------------------------------------------------
// Painter
// ---------------------------------------------------------
class _GlobePainter extends CustomPainter {
  const _GlobePainter({
    required this.assets,
    required this.geo,
    required this.dots,
    required this.centerLng,
    required this.centerLat,
    required this.cloudOffset,
    required this.selectedKey,
  });

  final _GlobeAssets? assets;
  final List<_GeoCountry> geo;
  final List<_Dot> dots;
  final double centerLng, centerLat, cloudOffset;
  final String? selectedKey;

  // Arah cahaya (kanan-atas-depan), tetap terhadap penonton.
  static const _lx = .52, _ly = .38, _lz = .76;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = _globeRadius(size);
    final sphere = Rect.fromCircle(center: center, radius: radius);
    final a = assets;

    if (a == null) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-.4, -.45),
            radius: 1.1,
            colors: [Color(0xFF2E6DB4), Color(0xFF123A73), Color(0xFF040F24)],
            stops: [0, .6, 1],
          ).createShader(sphere),
      );
      return;
    }

    final view = _View(centerLng, centerLat);

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    // Permukaan bumi (Blue Marble + relief).
    _drawLayer(
      canvas,
      a,
      view,
      center,
      radius,
      a.earthShader,
      a.earthTex,
      cloud: false,
      light: view,
    );
    // Awan, berputar sedikit lebih cepat dari bumi.
    _drawLayer(
      canvas,
      a,
      _View(centerLng - cloudOffset, centerLat),
      center,
      radius * 1.012,
      a.cloudShader,
      a.cloudTex,
      cloud: true,
      light: view,
    );
    // Pembayangan tepi bola (limb darkening) agar terasa 3D.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.3, -.3),
          radius: 1.25,
          colors: const [Color(0x00000000), Color(0x00000000), Color(0x66010A14)],
          stops: const [0, .62, 1],
        ).createShader(sphere),
    );

    // Garis batas negara (putih tipis, seperti di web).
    final border = Path();
    for (final country in geo) {
      for (final ring in country.rings) {
        var down = false;
        for (var i = 0; i < ring.length; i++) {
          final p = view.project(ring.ux[i], ring.uy[i], ring.uz[i]);
          if (p.z < .01) {
            down = false;
            continue;
          }
          final dx = center.dx + p.x * radius, dy = center.dy - p.y * radius;
          if (down) {
            border.lineTo(dx, dy);
          } else {
            border.moveTo(dx, dy);
            down = true;
          }
        }
      }
    }
    canvas.drawPath(
      border,
      Paint()
        ..color = const Color(0x59FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..strokeJoin = StrokeJoin.round,
    );

    // Negara terpilih: isian emas (rgba 240,201,138,.55 di web).
    for (final country in geo) {
      if (selectedKey != 'geo:${country.iso3}') continue;
      final fill = Path();
      for (final ring in country.rings) {
        for (var i = 0; i < ring.length; i++) {
          final p = view.project(ring.ux[i], ring.uy[i], ring.uz[i]);
          var dx = p.x, dy = p.y;
          if (p.z < 0) {
            // Titik di belakang bola dijepit ke tepi agar isian tetap utuh.
            final h = math.sqrt(dx * dx + dy * dy);
            if (h > 1e-6) {
              dx /= h;
              dy /= h;
            }
          }
          final sx = center.dx + dx * radius, sy = center.dy - dy * radius;
          i == 0 ? fill.moveTo(sx, sy) : fill.lineTo(sx, sy);
        }
        fill.close();
      }
      canvas.drawPath(fill, Paint()..color = const Color(0x8CF0C98A));
      canvas.drawPath(
        fill,
        Paint()
          ..color = const Color(0xFFFFE9B8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    // Negara kecil tanpa poligon.
    for (final dot in dots) {
      final p = view.project(dot.ux, dot.uy, dot.uz);
      if (p.z < .05) continue;
      final o = Offset(center.dx + p.x * radius, center.dy - p.y * radius);
      final selected = selectedKey == 'dot:${dot.id}';
      canvas.drawCircle(
        o,
        selected ? 6.5 : 4,
        Paint()..color = const Color(0x66F0C98A),
      );
      canvas.drawCircle(
        o,
        selected ? 3.6 : 2.2,
        Paint()..color = const Color(0xFFFFE066),
      );
    }
    canvas.restore();
  }

  void _drawLayer(
    Canvas canvas,
    _GlobeAssets a,
    _View view,
    Offset center,
    double radius,
    ui.Shader shader,
    Float32List tex, {
    required bool cloud,
    required _View light,
  }) {
    final n = _Sphere.count;
    final pos = a.pos, vz = a.vz, col = a.col;
    final ux = _Sphere.ux, uy = _Sphere.uy, uz = _Sphere.uz;
    for (var k = 0; k < n; k++) {
      final x = ux[k] * view.cosL - uz[k] * view.sinL;
      final z1 = ux[k] * view.sinL + uz[k] * view.cosL;
      final y = view.cosP * uy[k] - view.sinP * z1;
      final z = view.sinP * uy[k] + view.cosP * z1;
      pos[k * 2] = (center.dx + x * radius).toDouble();
      pos[k * 2 + 1] = (center.dy - y * radius).toDouble();
      vz[k] = z;
      // Cahaya tetap terhadap penonton (tidak ikut perputaran awan).
      final lx = ux[k] * light.cosL - uz[k] * light.sinL;
      final lz1 = ux[k] * light.sinL + uz[k] * light.cosL;
      final sx = lx;
      final sy = light.cosP * uy[k] - light.sinP * lz1;
      final sz = light.sinP * uy[k] + light.cosP * lz1;
      final lit = math.max(0.0, sx * _lx + sy * _ly + sz * _lz);
      final m = (.66 + .34 * lit).clamp(0.0, 1.0);
      final g = (m * 255).round();
      final alpha = cloud ? 140 : 255;
      col[k] = (alpha << 24) | (g << 16) | (g << 8) | g;
    }

    // Segitiga yang menghadap penonton saja.
    final idx = a.idx;
    var c = 0;
    const cols = _Sphere.cols;
    for (var i = 0; i < _Sphere.latN; i++) {
      for (var j = 0; j < _Sphere.lonN; j++) {
        final p = i * cols + j, q = p + 1, r = p + cols, s = r + 1;
        if (vz[p] > -.04 && vz[r] > -.04 && vz[q] > -.04) {
          idx[c++] = p;
          idx[c++] = r;
          idx[c++] = q;
        }
        if (vz[q] > -.04 && vz[r] > -.04 && vz[s] > -.04) {
          idx[c++] = q;
          idx[c++] = r;
          idx[c++] = s;
        }
      }
    }
    if (c == 0) return;
    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      pos,
      textureCoordinates: tex,
      colors: col,
      indices: Uint16List.sublistView(idx, 0, c),
    );
    canvas.drawVertices(
      vertices,
      BlendMode.modulate,
      Paint()
        ..shader = shader
        ..filterQuality = FilterQuality.medium
        ..isAntiAlias = true,
    );
    vertices.dispose();
  }

  @override
  bool shouldRepaint(covariant _GlobePainter old) =>
      old.centerLng != centerLng ||
      old.centerLat != centerLat ||
      old.cloudOffset != cloudOffset ||
      old.selectedKey != selectedKey ||
      old.assets != assets ||
      old.geo.length != geo.length ||
      old.dots.length != dots.length;
}
