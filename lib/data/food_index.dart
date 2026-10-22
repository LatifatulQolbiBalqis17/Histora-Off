import 'package:flutter/services.dart';
import 'models.dart';

/// Satu foto makanan (dibaca dari nama file di assets/images/foods/).
class FoodItem {
  const FoodItem({
    required this.name,
    this.ingredients = '',
    this.description = '',
    required this.image,
  });
  final String name, ingredients, description, image;
}

/// Mencocokkan foto makanan berdasarkan NAMA FILE ("negara - makanan.jpeg"),
/// sehingga foto tidak perlu diganti namanya. Yang dibaca hanya nama negara
/// di depan tanda "-" (huruf besar/kecil dan spasi diabaikan).
class FoodIndex {
  /// kode negara -> daftar (kunci nama negara di file, nama makanan yang rapi)
  static const _entries = <String, List<(String, String)>>{
    'ad': [('andorra', "Escudella")],
    'ae': [('uniemiratarab', "Harees")],
    'af': [('afghanistan', "Kabuli Pulao")],
    'ag': [('antiguadanbarbuda', "Fungee and Pepperpot")],
    'al': [('albania', "Tavë Kosi")],
    'am': [('armenia', "Harissa")],
    'ar': [('argentian', "Asado")],
    'at': [('austria', "Wiener Schnitzel")],
    'au': [('australia', "Meat Pie")],
    'az': [('azebaijan', "Plov")],
    'ba': [('bosniadanherzegovina', "Ćevapi")],
    'bb': [('barbados', "Cou-Cou and Flying Fish")],
    'bd': [('bangladesh', "Hilsa Curry")],
    'be': [('belgia', "Moules-Frites")],
    'bg': [('bulgaria', "Banitsa")],
    'bh': [('bahrain', "Machboos")],
    'bn': [('bruneidarussalam', "Ambuyat")],
    'bo': [('bolivia', "Salteñas")],
    'br': [('brasil', "Feijoada")],
    'bs': [('bahama', "Conch Salad")],
    'bt': [('bhutan', "Ema Datshi")],
    'by': [('belarus', "Draniki")],
    'bz': [('belize', "Rice and Beans")],
    'ca': [('kanada', "Poutine")],
    'ch': [('swiss', "Cheese Fondue")],
    'cl': [('cile', "Pastel de Choclo")],
    'cn': [('tiongkok', "Peking Duck")],
    'co': [('kolombia', "Bandeja Paisa")],
    'cr': [('kostarika', "Gallo Pinto")],
    'cu': [('kuba', "Ropa Vieja")],
    'cy': [('siprus', "Souvla")],
    'cz': [('ceko', "Svíčková")],
    'de': [('jerman', "Bratwurst")],
    'dk': [('denmarksmorrebrod', "Smørrebrød")],
    'dm': [('dominika', "Callaloo Soup")],
    'ec': [('ekuador', "Encebollado")],
    'ee': [('estonia', "Verivorst")],
    'es': [('spanyol', "Paella")],
    'fi': [('finlandia', "Karjalanpiirakka")],
    'fm': [('federasimikronesia', "Sup Kelapa dan Ikan")],
    'fr': [('prancis', "Ratatouille")],
    'gb': [('britaniaraya', "Fish and Chips")],
    'gd': [('grenada', "Oil Down")],
    'ge': [('georgia', "Khachapuri")],
    'gr': [('yunani', "Moussaka")],
    'gt': [('guetemala', "Pepián")],
    'gy': [('guyana', "Pepperpot")],
    'hn': [('honduras', "Baleadas")],
    'hr': [('kroasia', "Peka")],
    'ht': [('haiti', "Soup Joumou")],
    'hu': [('hungaria', "Goulash")],
    'id': [('indonesia', "Rendang")],
    'ie': [('irlandia', "Irish Stew")],
    'il': [('israel', "Shakshuka")],
    'in': [('india', "Biryani")],
    'iq': [('irak', "Masgouf")],
    'ir': [('iran', "Chelo Kebab")],
    'is': [('islandia', "Plokkfiskur")],
    'it': [('italia', "Pizza")],
    'jm': [('jamaika', "Jerk Chicken")],
    'jo': [('yordania', "Mansaf")],
    'jp': [('jepang', "Sushi")],
    'kg': [('kirgizstan', "Beshbarmak")],
    'kh': [('kamboja', "Fish Amok")],
    'ki': [('kiribati', "Te Bua Toro ni Baukin")],
    'kn': [('saintkittsdannevis', "Goat Water Stew")],
    'kp': [('koreautara', "Naengmyeon")],
    'kr': [('koreaselatan', "Kimchi")],
    'kw': [('kuwait', "Muttabaq Samak")],
    'kz': [('kazakhstan', "Bashbarmak")],
    'la': [('laos', "Larb")],
    'lb': [('lebanon', "Tabbouleh")],
    'lc': [('saintlucia', "Green Fig and Saltfish")],
    'li': [('liechtenstein', "Käsknöpfle")],
    'lk': [('srilanka', "Kottu Roti")],
    'lt': [('lituania', "Cepelinai")],
    'lu': [('luksemburg', "Judd mat Gaardebounen")],
    'lv': [('latvia', "Pelēkie Zirņi ar Speķi")],
    'mc': [('monako', "Barbajuan")],
    'md': [('moldova', "Mămăligă")],
    'me': [('montenegro', "Kačamak")],
    'mh': [('kepulauanmarshall', "Barramundi Panggang")],
    'mk': [('makedoniautara', "Tavče Gravče")],
    'mm': [('myanmar', "Mohinga")],
    'mn': [('mongolia', "Buuz")],
    'mt': [('malta', "Stuffat tal-Fenek")],
    'mv': [('maladewa', "Mas Huni")],
    'mx': [('meksiko', "Tacos")],
    'my': [('malaysia', "Nasi Lemak")],
    'ni': [('nikagarua', "Nacatamales")],
    'nl': [('belanda', "Stamppot")],
    'no': [('norwegia', "Fårikål")],
    'np': [('nepal', "Dal Bhat")],
    'nr': [('nauru', "Ikan Kelapa")],
    'nz': [('selandiabaru', "Hangi")],
    'om': [('oma', "Shuwa")],
    'pa': [('panama', "Sancocho")],
    'pe': [('peru', "Ceviche")],
    'pg': [('pulaunugini', "Mumu")],
    'ph': [('filipina', "Adobo")],
    'pk': [('pakistan', "Nihari")],
    'pl': [('polandia', "Pierogi")],
    'ps': [('palestina', "Musakhan")],
    'pt': [('portugal', "Bacalhau")],
    'pw': [('palau', "Ulkoy")],
    'py': [('paraguay', "Sopa Paraguaya")],
    'qa': [('qatar', "Harees")],
    'ro': [('rumania', "Sarmale")],
    'rs': [('serbia', "Pljeskavica")],
    'ru': [('rusia', "Pelmeni")],
    'sa': [('arabsaudi', "Kabsa")],
    'sb': [('kepulauansolomon', "Poi Talas")],
    'se': [('swedia', "Köttbullar")],
    'sg': [('singapura', "Hainanese Chicken Rice")],
    'si': [('slovenia', "Kranjska Klobasa")],
    'sk': [('slovakia', "Bryndzové Halušky")],
    'sm': [('sanmarino', "Torta Tre Monti")],
    'sr': [('suriname', "Pom")],
    'sv': [('elsalvador', "Pupusas")],
    'sy': [('suriah', "Kibbeh")],
    'th': [('thailand', "Pad Thai")],
    'tj': [('tajikistan', "Qurutob")],
    'tl': [('timorleste', "Ikan Sabuko")],
    'tm': [('turkmenistan', "Içlekli")],
    'to': [('tonga', "Lu Pulu")],
    'tr': [('turki', "Doner Kebab")],
    'tt': [('trinidaddantobago', "Doubles")],
    'tv': [('tuvalu', "Pulaka")],
    'ua': [('ukraina', "Borscht")],
    'us': [('amerikatserikat', "Hamburger")],
    'uy': [('uruguay', "Chivito")],
    'uz': [('uzbekistan', "Plov")],
    'vc': [('saintvincentdangradaniea', "Roasted Breadfruit and Fried Jackfish")],
    've': [('venezuela', "Pabellon Criollo")],
    'vn': [('vietnam', "Pho")],
    'vu': [('vanuata', "Laplap")],
    'ws': [('samoa', "Palusami")],
    'ye': [('yaman', "Saltah")],
  };

  static final Map<String, List<FoodItem>> _byId = {};

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static final _split = RegExp(r'\s+-\s*|\s*-\s+');
  static final _ext = RegExp(r'(\.jpe?g|\.png|\.webp)+$', caseSensitive: false);

  static Future<void> build() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final byKey = <String, String>{};
      for (final path in manifest.listAssets()) {
        if (!path.startsWith('assets/images/foods/')) continue;
        final file = path.split('/').last;
        if (!_ext.hasMatch(file)) continue;
        final base = file.replaceFirst(_ext, '');
        final m = _split.firstMatch(base);
        // file tanpa tanda "-" memakai seluruh namanya sebagai kunci
        byKey[_norm(m == null ? base : base.substring(0, m.start))] = path;
      }
      _byId.clear();
      for (final e in _entries.entries) {
        for (final (key, name) in e.value) {
          final path = byKey[key];
          if (path != null) {
            (_byId[e.key] ??= []).add(FoodItem(name: name, image: path));
          }
        }
      }
    } catch (_) {}
  }

  /// Daftar makanan untuk tab "Kuliner": data countries.json + foto Anda.
  static List<FoodItem> itemsFor(Country c) {
    final photos = _byId[c.id] ?? const <FoodItem>[];
    final used = <FoodItem>{};
    final items = <FoodItem>[];
    for (final f in c.foods) {
      String image = f.image;
      for (final ph in photos) {
        final a = _norm(f.name), b = _norm(ph.name);
        if (a.contains(b) || b.contains(a)) {
          image = ph.image;
          used.add(ph);
          break;
        }
      }
      items.add(FoodItem(
        name: f.name,
        ingredients: f.ingredients,
        description: f.description,
        image: image,
      ));
    }
    final extra = photos
        .where((ph) => !used.contains(ph))
        .map((ph) => FoodItem(name: ph.name, image: ph.image));
    return [...extra, ...items];
  }
}
