/// Data game Cerita Interaktif.
/// 3 cerita pendek dengan 2-3 pilihan per halaman.
/// Mendukung branching (pilihan menentukan alur cerita).

class CeritaInteraktifData {
  static const String gameType = 'Cerita Interaktif';

  static int get scorePerRound => 20;

  /// Struktur cerita: id, judul, emoji, halaman[]
  /// Masing-masing halaman: teks, pilihan[] (label + halaman berikutnya)
  static const List<Map<String, dynamic>> stories = [
    {
      'id': 'mau_makan',
      'title': 'Ali Ingin Makan',
      'emoji': '🍽️',
      'ageCategory': ' toddler',
      'pages': [
        {
          'text': 'Ali sedang lapar. Terus-terusan bilang "lapar". 🤔',
          'choices': [
            {'label': '🍚 Makan nasi', 'next': 1},
            {'label': '😴 Tidur dulu', 'next': 2},
          ],
        },
        {
          'text': 'Ali makan nasi hangat dengan lauk ayam. Enak! 🍗',
          'choices': [
            {'label': '⚽ Main bola', 'next': 3},
            {'label': '😴 Tidur', 'next': 3},
          ],
        },
        {
          'text': 'Ali tidur sebentar... tapi masih lapar 😢',
          'choices': [
            {'label': '🍚 Makan nasi', 'next': 3},
          ],
        },
        {
          'text': 'Ali kenyang dan bahagia! Hari yang menyenangkan! 🎉',
          'choices': [],
        },
      ],
    },
    {
      'id': 'main_taman',
      'title': 'Ali Bermain di Taman',
      'emoji': '🌳',
      'ageCategory': 'toddler',
      'pages': [
        {
          'text': 'Ali pergi ke taman. Ada banyak mainan! 🎈',
          'choices': [
            {'label': '⚽ Main bola', 'next': 1},
            {'label': '🎠 Ayunan', 'next': 1},
          ],
        },
        {
          'text': 'Ali bermain dengan seru. Lalu bertemu teman! 👦',
          'choices': [
            {'label': '🤝 Main bersama', 'next': 2},
            {'label': '🏃 Main sendiri', 'next': 2},
          ],
        },
        {
          'text': 'Ali bersenang-senang dan pulang dengan senyum! 😊',
          'choices': [],
        },
      ],
    },
    {
      'id': 'pergi_dokter',
      'title': 'Ali Pergi ke Dokter',
      'emoji': '🩺',
      'ageCategory': 'preschool',
      'pages': [
        {
          'text': 'Ali demam dan tidak enak badan. Harus ke dokter? 🤒',
          'choices': [
            {'label': '🏥 Pergi ke dokter', 'next': 1},
            {'label': '😴 Tidur saja', 'next': 2},
          ],
        },
        {
          'text': 'Dokter memeriksa Ali dengan ramah. "Tidak apa-apa!" 💊',
          'choices': [
            {'label': '💧 Minum obat', 'next': 3},
          ],
        },
        {
          'text': 'Ali merasa lebih baik setelah istirahat. 😊',
          'choices': [
            {'label': '💧 Minum air banyak', 'next': 3},
          ],
        },
        {
          'text': 'Ali sembuh dan bisa main lagi! Sehat itu penting! 🌟',
          'choices': [],
        },
      ],
    },
  ];

  /// Ambil cerita berdasarkan index
  static Map<String, dynamic>? getStory(int index) {
    if (index < 0 || index >= stories.length) return null;
    return stories[index];
  }

  /// Semua cerita
  static List<Map<String, dynamic>> get allStories => stories;

  /// Score per correct page (semua page yang dijawab = benar)
  static int pagesScore(int totalPages) => scorePerRound * totalPages;
}