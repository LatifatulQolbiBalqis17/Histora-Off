import 'package:flutter/services.dart';
import 'models.dart';

/// Satu foto tempat (dibaca dari nama file di assets/images/places/).
class PlaceItem {
  const PlaceItem({
    required this.name,
    this.city = '',
    this.description = '',
    required this.image,
  });
  final String name, city, description, image;
}

/// Mencocokkan foto tempat berdasarkan NAMA FILE ("NEGARA - TEMPAT.jpeg"),
/// sehingga foto tidak perlu diganti namanya. Yang dibaca hanya bagian
/// nama negara sebelum tanda "-" (huruf besar/kecil dan spasi diabaikan).
class PlaceIndex {
  /// kode negara -> daftar (kunci nama negara di file, nama tempat yang rapi)
  static const _entries = <String, List<(String, String)>>{
    'ae': [('uniemiratarab', "Burj Khalifa")],
    'af': [('afganistan', "Lembah Bamiyan")],
    'ag': [('antiguadanbarbuda', "Pantai Dickenson Bay")],
    'am': [('armenia', "Biara Geghard")],
    'ao': [('angola', "Air Terjun Kalandula")],
    'ar': [('argentina', "Air Terjun Iguazu")],
    'au': [('australia', "Sydney Opera House")],
    'az': [('azerbaijan', "Flame Towers")],
    'bb': [('barbados', "Pantai Carlisle Bay")],
    'bd': [('bangladesh', "Pantai Cox's Bazar")],
    'bf': [('burkinafaso', "Reruntuhan Loropeni")],
    'bh': [('bahrain', "Bahrain World Trade Center")],
    'bi': [('burundi', "Danau Tanganyika")],
    'bj': [('benin', "Desa Terapung Ganvie")],
    'bn': [('bruneidarusalam', "Masjid Sultan Omar Ali Saifuddien")],
    'bo': [('bolivia', "Salar de Uyuni")],
    'br': [('brasil', "Patung Kristus Penebus (Cristo Redentor)")],
    'bs': [('bahama', "Pantai Pink Sands")],
    'bt': [('bhutan', "Biara Tiger's Nest")],
    'bw': [('botswana', "Delta Okavango")],
    'bz': [('belize', "Great Blue Hole")],
    'ca': [('kanada', "Air Terjun Niagara")],
    'cd': [('republikdemoktratikkongo', "Taman Nasional Virunga")],
    'cf': [('republikafrikatengah', "Taman Nasional Dzangha-Sangha")],
    'cg': [('republikkongo', "Taman Nasional Odzala-Kokoua")],
    'ci': [('pantaigading', "Basilika Notre-Dame de la Paix")],
    'cl': [('cile', "Gurun Atacama")],
    'cm': [('kamerun', "Gunung Kamerun")],
    'cn': [('tiongkok', "Tembok Besar Tiongkok")],
    'co': [('kolombia', "Kota Cartagena")],
    'cr': [('kostarika', "Gunung Berapi Arenal")],
    'cu': [('kuba', "Kota Tua Havana")],
    'cv': [('caboverde', "Gunung Berapi Pico do Fogo"), ('tanjungverde', "Pantai Santa Maria")],
    'cy': [('siprus', "Petra tou Romiou")],
    'dj': [('djibouti', "Danau Assal")],
    'dm': [('dominika', "Danau Boiling Lake")],
    'do': [('republikdominika', "Punta Cana")],
    'dz': [('aljazair', "Kasbah Aljir")],
    'ec': [('ekuador', "Kepulauan Galapagos")],
    'eg': [('mesir', "Piramida Giza")],
    'er': [('eritrea', "Kota Asmara")],
    'et': [('etiopia', "Gereja Batu Lalibela")],
    'fj': [('fiji', "Kepulauan Mamanuca")],
    'fm': [('federasimikronesia', "Nan Madol")],
    'gd': [('grenada', "Pantai Grand Anse")],
    'ge': [('georgia', "Kota Tua Tbilisi")],
    'gh': [('ghana', "Kastil Cape Coast")],
    'gm': [('gambia', "Pulau Kunta Kinteh")],
    'gn': [('guinea', "Dataran Tinggi Fouta Djallon")],
    'gq': [('guineakhatulistiwa', "Katedral Malabo")],
    'gt': [('guatemala', "Situs Maya Tikal")],
    'gw': [('guineabissau', "Kepulauan Bijagos")],
    'gy': [('guyana', "Air Terjun Kaieteur")],
    'hn': [('honduras', "Reruntuhan Copán")],
    'ht': [('haiti', "Benteng Citadelle Laferrière")],
    'id': [('indonesia', "Candi Borobudur")],
    'il': [('israel', "Kota Tua Yerusalem")],
    'in': [('india', "Taj Mahal")],
    'iq': [('irak', "Ziggurat Ur")],
    'ir': [('iran', "Persepolis")],
    'jm': [('jamaika', "Air Terjun Dunn's River")],
    'jo': [('yordania', "Petra")],
    'jp': [('jepang', "Gunung Fuji")],
    'ke': [('kenya', "Cagar Alam Maasai Mara")],
    'kg': [('kirgizstan', "Danau Issyk-Kul")],
    'kh': [('kamboja', "Angkor Wat")],
    'ki': [('kiribati', "Pulau Kiritimati")],
    'km': [('komoro', "Gunung Karthala")],
    'kn': [('saintkittsdannevis', "Brimstone Hill Fortress")],
    'kp': [('koerautara', "Menara Juche")],
    'kr': [('koreaselatan', "Istana Gyeongbokgung")],
    'kw': [('kuwait', "Menara Kuwait")],
    'kz': [('kazakhstan', "Menara Baiterek")],
    'la': [('laos', "Pha That Luang")],
    'lb': [('lebanon', "Gua Jeita")],
    'lc': [('saintlucia', "Pegunungan Pitons")],
    'lk': [('srilanka', "Sigiriya")],
    'lr': [('liberia', "Pulau Providence")],
    'ls': [('lesotho', "Pegunungan Maloti")],
    'ly': [('libdya', "Kota Kuno Leptis Magna")],
    'ma': [('maroko', "Kota Chefchaouen")],
    'mg': [('madagaskar', "Avenue of the Baobabs")],
    'mh': [('kepulauanmarshal', "Bikini Atol")],
    'ml': [('mali', "Masjid Agung Djenne")],
    'mm': [('myanmar', "Pagoda Shwedagon")],
    'mn': [('mongolia', "Gurun Gobi")],
    'mr': [('mauritania', "Struktur Richat")],
    'mu': [('mauritius', "Air Terjun Chamarel")],
    'mv': [('maladewa', "Pantai dan Pulau Atol Maladewa")],
    'mw': [('malawi', "Danau Malawi")],
    'mx': [('meksiko', "Chichen Itza")],
    'my': [('malaysia', "Menara Kembar Petronas")],
    'mz': [('mozambik', "Kepulauan Bazaruto")],
    'na': [('namibia', "Gurun Sossusvlei")],
    'ne': [('niger', "Kota Agadez")],
    'ng': [('nigeria', "Zuma Rock")],
    'ni': [('nikaragua', "Pulau Ometepe")],
    'np': [('nepal', "Gunung Everest")],
    'nr': [('nauru', "Anibare Bay")],
    'nz': [('selandiabaru', "Milford Sound")],
    'om': [('oman', "Masjid Agung Sultan Qaboos")],
    'pa': [('panama', "Terusan Panama")],
    'pe': [('peru', "Machu Picchu")],
    'pg': [('papuanugini', "Kokoda Track")],
    'ph': [('filipina', "Pulau Boracay")],
    'pk': [('pakistan', "Masjid Faisal")],
    'ps': [('palestina', "Masjid Al Aqsa")],
    'pw': [('palau', "Rok Island")],
    'py': [('paraguay', "Bendungan Itaipu")],
    'qa': [('qatar', "Museum Seni Islam, Doha")],
    'rw': [('rwanda', "Taman Nasional Volcanoes")],
    'sa': [('arabsaudi', "Masjidil Haram")],
    'sb': [('kepulauansolomon', "Pulau Guadalcanal")],
    'sc': [('seychelles', "Pantai Anse Source d'Argent")],
    'sd': [('sudan', "Piramida Meroe")],
    'sg': [('singapura', "Marina Bay Sands")],
    'sl': [('sierraleone', "Pantai River No. 2")],
    'sn': [('senegal', "Pulau Goree")],
    'so': [('somalia', "Pantai Liido")],
    'sr': [('suriname', "Pusat Bersejarah Paramaribo")],
    'ss': [('sudanselatan', "Taman Nasional Boma")],
    'st': [('saotomedanprincipe', "Pico Cao Grande")],
    'sv': [('elsalvador', "Danau Caotepeque")],
    'sy': [('suriah', "Kota Kuno Damaskus")],
    'sz': [('eswatini', "Cagar Alam Hlane")],
    'td': [('chad', "Danau Chad")],
    'tg': [('togo', "Desa Togoville")],
    'th': [('thailand', "Wat Arun")],
    'tj': [('tajikistan', "Pegunungan Pamir")],
    'tl': [('timorleste', "Patung Cristo Rei, Dili")],
    'tm': [('turkmenistan', "Kawah Gas Darvaza")],
    'tn': [('tunisia', "Amfiteater El Jem")],
    'to': [('tonga', "Mapu'a 'a Vaea Blowholes")],
    'tr': [('turki', "Hagia Sophia")],
    'tt': [('trinidaddantobago', "Maracas Bay")],
    'tv': [('tuvalu', "Funafuti Conservation Area")],
    'tz': [('tanzania', "Gunung Kilimanjaro")],
    'ug': [('uganda', "Taman Nasional Bwindi")],
    'us': [('amerikaserikat', "Patung Liberty")],
    'uy': [('uruguay', "Pantai Punta Del Este")],
    'uz': [('uzbekistan', "Registan, Samarkand")],
    'vc': [('saintvincentdangrenadines', "Tobago Cays")],
    've': [('venezuela', "Air Terjun Angel")],
    'vn': [('vietnam', "Teluk Ha Long")],
    'vu': [('vanuatu', "Gunung Yasur")],
    'ws': [('samoa', "To Sua Ocean Trench")],
    'ye': [('yaman', "Kota Tua Sana'a")],
    'za': [('afrikaselatan', "Table Mountain")],
    'zm': [('zambia', "Air Terjun Victoria")],
  };

  static final Map<String, List<PlaceItem>> _byId = {};

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static final _split = RegExp(r'\s+-\s*|\s*-\s+');
  static final _ext = RegExp(r'(\.jpe?g|\.png|\.webp)+$', caseSensitive: false);

  static Future<void> build() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final byKey = <String, String>{};
      for (final path in manifest.listAssets()) {
        if (!path.startsWith('assets/images/places/')) continue;
        final file = path.split('/').last;
        if (!_ext.hasMatch(file)) continue;
        final base = file.replaceFirst(_ext, '');
        final m = _split.firstMatch(base);
        if (m == null) continue;
        byKey[_norm(base.substring(0, m.start))] = path;
      }
      _byId.clear();
      for (final e in _entries.entries) {
        for (final (key, name) in e.value) {
          final path = byKey[key];
          if (path != null) {
            (_byId[e.key] ??= []).add(PlaceItem(name: name, image: path));
          }
        }
      }
    } catch (_) {}
  }

  /// Foto tempat pertama untuk negara ini (dipakai sebagai gambar utama).
  static String? photoFor(String id) {
    final list = _byId[id];
    return (list == null || list.isEmpty) ? null : list.first.image;
  }

  /// Daftar tempat untuk tab "Tempat": data dari countries.json + foto Anda.
  static List<PlaceItem> itemsFor(Country c) {
    final photos = _byId[c.id] ?? const <PlaceItem>[];
    final used = <PlaceItem>{};
    final items = <PlaceItem>[];
    for (final p in c.places) {
      String image = p.image;
      for (final ph in photos) {
        final a = _norm(p.name), b = _norm(ph.name);
        if (a.contains(b) || b.contains(a)) {
          image = ph.image;
          used.add(ph);
          break;
        }
      }
      items.add(PlaceItem(
        name: p.name,
        city: p.city,
        description: p.description,
        image: image,
      ));
    }
    final extra = photos
        .where((ph) => !used.contains(ph))
        .map((ph) => PlaceItem(name: ph.name, city: c.name, image: ph.image));
    return [...extra, ...items];
  }
}
