/// Data game Suara Binatang.
/// Semua kata/suara di-hardcode di sini — mudah ditambah/diedit.

class SuaraBinatangData {
  static const String gameType = 'Suara Binatang';

  /// Item hewan: id, nama, emoji, nama file audio (placeholder).
  /// Untuk MVP, audio masih disimulasi (snackbar).
  /// Nanti bisa ditambahkan suara MP3 di assets/sounds/.
  static const List<Map<String, String>> items = [
    {'id': 'kucing',  'name': 'Kucing',   'emoji': '🐱'},
    {'id': 'anjing',  'name': 'Anjing',   'emoji': '🐶'},
    {'id': 'sapi',    'name': 'Sapi',     'emoji': '🐮'},
    {'id': 'ayam',    'name': 'Ayam',     'emoji': '🐔'},
    {'id': 'kuda',    'name': 'Kuda',     'emoji': '🐴'},
    {'id': 'bebek',   'name': 'Bebek',   'emoji': '🦆'},
    {'id': 'kambing', 'name': 'Kambing', 'emoji': '🐐'},
    {'id': 'gajah',   'name': 'Gajah',    'emoji': '🐘'},
    {'id': 'merpati', 'name': 'Merpati',  'emoji': '🐦'},
    {'id': 'babi',    'name': 'Babi',     'emoji': '🐷'},
  ];

  /// Scoring per ronde: 20 poin kalau benar
  static int get scorePerRound => 20;

  /// Ambil N ronde acak dari daftar hewan
  static List<Map<String, String>> getRounds(int count) {
    final shuffled = List<Map<String, String>>.from(items)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Generate pilihan acak (termasuk jawaban benar + distractors)
  static List<Map<String, String>> generateChoices(
    Map<String, String> correctAnswer,
    int choiceCount,
  ) {
    final others = items
        .where((item) => item['id'] != correctAnswer['id'])
        .toList()
      ..shuffle();
    final distractors = others.take(choiceCount - 1).toList();
    final choices = [correctAnswer, ...distractors]..shuffle();
    return choices;
  }
}