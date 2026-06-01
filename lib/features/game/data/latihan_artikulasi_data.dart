/// Data game Latihan Artikulasi.
/// Kata-kata dengan bunyi sulit untuk anak 3-5 tahun: R, S, L, N.
/// Untuk umur 36-60 bulan — fokus articulation, bukan vocabulary.

class LatihanArtikulasiData {
  static const String gameType = 'Latihan Artikulasi';

  /// Skor per ronde: ikut serta full = 15 poin (tanpa "salah")
  static int get scorePerRound => 15;

  /// Item kata: id, kata, emoji, target bunyi, deskripsi tips.
  static const List<Map<String, String>> items = [
    // Target 'R'
    {'id': 'rusuk',    'word': 'Rusuk',    'emoji': '🧱', 'target': 'R', 'tip': 'Gulungkan lidah ke atas, rrrr!'},
    {'id': 'rumah',    'word': 'Rumah',    'emoji': '🏠', 'target': 'R', 'tip': 'TEKAN huruf R, seperti geraman'},
    {'id': 'roti',     'word': 'Roti',     'emoji': '🍞', 'target': 'R', 'tip': 'Rrrr-oti, gulungkan lidah!'},
    {'id': 'biru',     'word': 'Biru',     'emoji': '🔵', 'target': 'R', 'tip': 'Bu-biru, tekan huruf R!'},
    {'id': 'lari',     'word': 'Lari',     'emoji': '🏃', 'target': 'R', 'tip': 'La-ri, rrrr di akhir!'},
    // Target 'S'
    {'id': 'sepatu',   'word': 'Sepatu',  'emoji': '👟', 'target': 'S', 'tip': 'Sssss... jangan pakai gigi bawah dulu'},
    {'id': 'sarung',   'word': 'Sarung',  'emoji': '🧣', 'target': 'S', 'tip': 'Saa-rung, ujung lidah di atas gigi'},
    {'id': 'sisir',    'word': 'Sisir',   'emoji': '🪮', 'target': 'S', 'tip': 'Sssss-isir, lidah di atas'},
    {'id': 'selamat',  'word': 'Selamat', 'emoji': '🎉', 'target': 'S', 'tip': 'Se-la-mat, Ssss panjang!'},
    {'id': 'susu',     'word': 'Susu',    'emoji': '🥛', 'target': 'S', 'tip': 'Su-su, SSS di depan'},
    // Target 'L'
    {'id': 'lampu',    'word': 'Lampu',   'emoji': '💡', 'target': 'L', 'tip': 'Lam-pu, ujung lidah tekan gigi atas'},
    {'id': 'lipat',    'word': 'Lipat',   'emoji': '📁', 'target': 'L', 'tip': 'Li-pat, L di depan'},
    {'id': 'langit',   'word': 'Langit',  'emoji': '🌤️', 'target': 'L', 'tip': 'Lang-it, Lrrr di depan'},
    {'id': 'lemon',    'word': 'Lemon',   'emoji': '🍋', 'target': 'L', 'tip': 'Le-mon, L di depan'},
    {'id': 'bunga_melati', 'word': 'Melati', 'emoji': '🌼', 'target': 'L', 'tip': 'Me-la-ti, L di tengah'},
    // Target 'N'
    {'id': 'nasi',     'word': 'Nasi',    'emoji': '🍚', 'target': 'N', 'tip': 'Na-si, N dari hidung'},
    {'id': 'nila',     'word': 'Nila',    'emoji': '🐟', 'target': 'N', 'tip': 'Ni-la, N dari hidung'},
    {'id': 'nuri',     'word': 'Nuri',    'emoji': '🦜', 'target': 'N', 'tip': 'Nu-ri, N dari hidung'},
    {'id': 'nenas',    'word': 'Nanas',   'emoji': '🍍', 'target': 'N', 'tip': 'Na-nas, N di depan'},
    {'id': 'narapidana', 'word': 'Tahanan', 'emoji': '🏢', 'target': 'N', 'tip': 'Ta-ha-nan, N di tengah'},
  ];

  /// Ambil N ronde acak
  static List<Map<String, String>> getRounds(int count) {
    final shuffled = List<Map<String, String>>.from(items)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Get rounds by target sound (untuk fokus bunyi tertentu)
  static List<Map<String, String>> getRoundsByTarget(int count, String target) {
    final filtered = items.where((item) => item['target'] == target).toList()
      ..shuffle();
    return filtered.take(count).toList();
  }

  /// Target bunyi yang tersedia
  static const List<String> targets = ['R', 'S', 'L', 'N'];

  static String targetLabel(String target) {
    const labels = {
      'R': 'Bunyi R —舌头卷起来!',
      'S': 'Bunyi S —舌尖放上面!',
      'L': 'Bunyi L —舌头顶上面!',
      'N': 'Bunyi N —从鼻子出声!',
    };
    return labels[target] ?? 'Bunyi $target';
  }
}