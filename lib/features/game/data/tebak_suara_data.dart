/// Data game Tebak Suara.
/// Suara lingkungan (kendaraan, alam, rumah) — bukan suara hewan.
/// Anak dengarkan → pilih gambar yang sesuai.

class TebakSuaraData {
  static const String gameType = 'Tebak Suara';

  static int get scorePerRound => 20;

  /// Item suara: id, nama, emoji, kategori, deskripsi teks (fallback MVP).
  static const List<Map<String, String>> items = [
    // Kendaraan
    {'id': 'klakson',   'name': 'Klakson',    'emoji': '🚗', 'category': 'Kendaraan'},
    {'id': 'siren',     'name': 'Siren',       'emoji': '🚓', 'category': 'Kendaraan'},
    {'id': 'peluit',    'name': 'Peluit',      'emoji': '🎵', 'category': 'Kendaraan'},
    {'id': 'kereta',    'name': 'Kereta',      'emoji': '🚂', 'category': 'Kendaraan'},
    {'id': 'kapal',     'name': 'Kapal',       'emoji': '🚢', 'category': 'Kendaraan'},
    // Alam
    {'id': 'petir',     'name': 'Petir',       'emoji': '⚡', 'category': 'Alam'},
    {'id': 'hujan',     'name': 'Hujan',        'emoji': '🌧️', 'category': 'Alam'},
    {'id': 'angin',     'name': 'Angin',        'emoji': '💨', 'category': 'Alam'},
    {'id': 'air',        'name': 'Air Mengalir', 'emoji': '💧', 'category': 'Alam'},
    {'id': 'burung',    'name': 'Burung',       'emoji': '🐦', 'category': 'Alam'},
    // Rumah
    {'id': 'bel',       'name': 'Bel Rumah',   'emoji': '🔔', 'category': 'Rumah'},
    {'id': 'ketukan',   'name': 'Ketukan Pintu','emoji': '🚪', 'category': 'Rumah'},
    {'id': 'telepon',   'name': 'Telepon',     'emoji': '📞', 'category': 'Rumah'},
    {'id': 'jam',       'name': 'Jam Dinding', 'emoji': '⏰', 'category': 'Rumah'},
  ];

  /// Ambil N ronde acak
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
        .where((item) => item['id'] != correctAnswer['id'])
        .toList()
      ..shuffle();
    final distractors = others.take(choiceCount - 1).toList();
    return [...distractors, correctAnswer]..shuffle();
  }

  static String categoryLabel(String category) {
    const labels = {
      'Kendaraan': 'Kendaraan',
      'Alam': 'Alam',
      'Rumah': 'Di Rumah',
    };
    return labels[category] ?? category;
  }
}