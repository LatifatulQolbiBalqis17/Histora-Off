class Country {
  const Country({
    required this.id,
    required this.name,
    required this.localName,
    required this.flagEmoji,
    required this.continent,
    required this.capital,
    required this.population,
    required this.area,
    required this.language,
    required this.currency,
    required this.timezone,
    required this.overview,
    required this.history,
    required this.places,
    required this.culture,
    required this.foods,
    required this.facts,
    this.flagImage = '',
    this.heroImage = '',
  });
  final String id,
      name,
      localName,
      flagEmoji,
      continent,
      capital,
      population,
      area,
      language,
      currency,
      timezone,
      overview,
      flagImage,
      heroImage;
  final List<HistoryEvent> history;
  final List<Place> places;
  final List<CultureItem> culture;
  final List<Food> foods;
  final List<String> facts;
  factory Country.fromJson(Map<String, dynamic> j) => Country(
    id: j['id'] as String? ?? '',
    name: j['name'] as String? ?? 'Tanpa nama',
    localName: j['localName'] as String? ?? j['name'] as String? ?? '-',
    flagEmoji: j['flagEmoji'] ?? '🌍',
    continent: j['continent'] as String? ?? '-',
    capital: j['capital'] as String? ?? '-',
    population: j['population'] as String? ?? '-',
    area: j['area'] as String? ?? '-',
    language: j['language'] as String? ?? '-',
    currency: j['currency'] as String? ?? '-',
    timezone: j['timezone'] as String? ?? '-',
    overview: j['overview'] as String? ?? 'Informasi belum tersedia.',
    flagImage: j['flagImage'] ?? '',
    heroImage: j['heroImage'] ?? '',
    history: (j['history'] as List? ?? const [])
        .map((e) => HistoryEvent.fromJson(e))
        .toList(),
    places: (j['places'] as List? ?? const []).map((e) => Place.fromJson(e)).toList(),
    culture: (j['culture'] as List? ?? const [])
        .map((e) => CultureItem.fromJson(e))
        .toList(),
    foods: (j['foods'] as List? ?? const []).map((e) => Food.fromJson(e)).toList(),
    facts: List<String>.from(j['facts'] as List? ?? const []),
  );
}

class HistoryEvent {
  const HistoryEvent(this.year, this.title, this.description);
  final String year, title, description;
  factory HistoryEvent.fromJson(Map<String, dynamic> j) =>
      HistoryEvent(j['year'], j['title'], j['description']);
}

class Place {
  const Place(this.name, this.city, this.description, this.image);
  final String name, city, description, image;
  factory Place.fromJson(Map<String, dynamic> j) =>
      Place(j['name'], j['city'], j['description'], j['image'] ?? '');
}

class CultureItem {
  const CultureItem(this.aspect, this.title, this.description);
  final String aspect, title, description;
  factory CultureItem.fromJson(Map<String, dynamic> j) =>
      CultureItem(j['aspect'], j['title'], j['description']);
}

class Food {
  const Food(this.name, this.ingredients, this.description, this.image);
  final String name, ingredients, description, image;
  factory Food.fromJson(Map<String, dynamic> j) =>
      Food(j['name'], j['ingredients'], j['description'], j['image'] ?? '');
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.category,
    required this.countryId,
    required this.text,
    required this.options,
    required this.answer,
    required this.explanation,
    this.image = '',
  });
  final String id, category, countryId, text, answer, explanation, image;
  final List<String> options;
  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
    id: j['id'],
    category: j['category'],
    countryId: j['countryId'],
    text: j['text'],
    options: List<String>.from(j['options']),
    answer: j['answer'],
    explanation: j['explanation'],
    image: j['image'] ?? '',
  );
}

class QuizRecord {
  const QuizRecord({
    required this.category,
    required this.score,
    required this.correct,
    required this.total,
    required this.seconds,
    required this.date,
  });
  final String category, date;
  final int score, correct, total, seconds;
}
