/// Data game Kata Bergambar.
/// 30+ kata dalam 4 kategori, dengan emoji.
/// Hint mode bisa 'highlight' (beri tahu benar setelah salah) atau 'none'.

class KataBergambarData {
  static const String gameType = 'Kata Bergambar';

  /// Skor per ronde
  static int get scorePerRound => 10;

  /// Semua kata: id, kata, emoji, kategori
  static const List<Map<String, String>> items = [
    // Hewan
    {'id': 'kucing',  'word': 'Kucing',   'emoji': '🐱', 'category': 'Hewan'},
    {'id': 'anjing',  'word': 'Anjing',   'emoji': '🐶', 'category': 'Hewan'},
    {'id': 'ayam',    'word': 'Ayam',     'emoji': '🐔', 'category': 'Hewan'},
    {'id': 'ikan',    'word': 'Ikan',     'emoji': '🐟', 'category': 'Hewan'},
    {'id': 'kuda',    'word': 'Kuda',     'emoji': '🐴', 'category': 'Hewan'},
    {'id': 'gajah',   'word': 'Gajah',    'emoji': '🐘', 'category': 'Hewan'},
    {'id': 'kupu',    'word': 'Kupu-kupu','emoji': '🦋', 'category': 'Hewan'},
    {'id': 'kangguru','word': 'Kangguru', 'emoji': '🦘', 'category': 'Hewan'},
    {'id': 'unta',    'word': 'Unta',     'emoji': '🐪', 'category': 'Hewan'},
    {'id': 'singa',   'word': 'Singa',    'emoji': '🦁', 'category': 'Hewan'},
    // Makanan
    {'id': 'nasi',    'word': 'Nasi',     'emoji': '🍚', 'category': 'Makanan'},
    {'id': 'apel',    'word': 'Apel',     'emoji': '🍎', 'category': 'Makanan'},
    {'id': 'pisang',  'word': 'Pisang',   'emoji': '🍌', 'category': 'Makanan'},
    {'id': 'roti',    'word': 'Roti',     'emoji': '🍞', 'category': 'Makanan'},
    {'id': 'susu',    'word': 'Susu',     'emoji': '🥛', 'category': 'Makanan'},
    {'id': 'eskrim',  'word': 'Eskrim',   'emoji': '🍦', 'category': 'Makanan'},
    {'id': 'jeruk',   'word': 'Jeruk',    'emoji': '🍊', 'category': 'Makanan'},
    {'id': 'pizza',   'word': 'Pizza',    'emoji': '🍕', 'category': 'Makanan'},
    // Benda
    {'id': 'mobil',   'word': 'Mobil',    'emoji': '🚗', 'category': 'Benda'},
    {'id': 'sepeda',  'word': 'Sepeda',   'emoji': '🚲', 'category': 'Benda'},
    {'id': 'buku',    'word': 'Buku',    'emoji': '📚', 'category': 'Benda'},
    {'id': 'bola',    'word': 'Bola',     'emoji': '⚽', 'category': 'Benda'},
    {'id': 'bunga',   'word': 'Bunga',   'emoji': '🌸', 'category': 'Benda'},
    {'id': 'jam',     'word': 'Jam',      'emoji': '⏰', 'category': 'Benda'},
    {'id': 'tas',     'word': 'Tas',      'emoji': '🎒', 'category': 'Benda'},
    {'id': 'sepatu',  'word': 'Sepatu',   'emoji': '👟', 'category': 'Benda'},
    // Alam & Tempat
    {'id': 'rumah',   'word': 'Rumah',   'emoji': '🏠', 'category': 'Alam'},
    {'id': 'pohon',   'word': 'Pohon',   'emoji': '🌳', 'category': 'Alam'},
    {'id': 'matahari','word': 'Matahari','emoji': '☀️', 'category': 'Alam'},
    {'id': 'bulan',   'word': 'Bulan',   'emoji': '🌙', 'category': 'Alam'},
    {'id': 'air',     'word': 'Air',      'emoji': '💧', 'category': 'Alam'},
    {'id': 'langit',  'word': 'Langit',  'emoji': '🌤️', 'category': 'Alam'},
    {'id': 'gunung',  'word': 'Gunung',  'emoji': '🏔️', 'category': 'Alam'},
    {'id': 'laut',    'word': 'Laut',    'emoji': '🌊', 'category': 'Alam'},
  ];

  /// Acak dan ambil N ronde
  static List<Map<String, String>> getRounds(int count) {
    final shuffled = List<Map<String, String>>.from(items)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Generate pilihan (jawaban benar + distractors)
  static List<Map<String, String>> generateChoices(
    Map<String, String> correctAnswer,
    int choiceCount,
  ) {
    final others = items
        .where((item) => item['id'] != correctAnswer['id'] && item['category'] == correctAnswer['category'])
        .toList()
      ..shuffle();
    final distractors = others.take(choiceCount - 1).toList();
    return [...distractors, correctAnswer]..shuffle();
  }

  /// Label kategori (display)
  static String categoryLabel(String category) {
    const labels = {
      'Hewan': 'Hewan',
      'Makanan': 'Makanan',
      'Benda': 'Benda',
      'Alam': 'Alam & Tempat',
    };
    return labels[category] ?? category;
  }
}