# Speech Therapy - Deteksi & Terapi Speech Delay Anak

Aplikasi Flutter untuk deteksi dan terapi speech delay pada anak dengan fitur lengkap untuk orang tua, terapis, dan admin.

## 🚀 Fitur Utama

### Untuk Orang Tua

- **Dashboard Interaktif** - Overview perkembangan anak
- **Data Anak (CRUD)** - Kelola data anak dengan lengkap
- **Konsultasi Online** - Konsultasi dengan terapis profesional
- **Hasil Diagnosa** - Lihat hasil assessment speech delay
- **Booking Jadwal Terapi** - Jadwalkan sesi terapi
- **Pembayaran Terintegrasi** - Pembayaran via Midtrans (Snap UI)
- **Game Terapi Interaktif**:
  - Menirukan suara hewan dan benda
  - Tebak gambar
  - Latihan suara dengan recording
  - Upload foto perkembangan
- **Edukasi & Materi** - Konten edukatif untuk orang tua
- **Riwayat & Laporan** - Tracking perkembangan anak

### Untuk Terapis

- **Dashboard Terapis** - Kelola pasien dan jadwal
- **Data Pasien** - Akses data anak yang ditangani
- **Monitoring Perkembangan** - Track progress terapi
- **Lihat Latihan Suara** - Review hasil latihan anak
- **Jadwal Terapi** - Kelola jadwal sesi terapi
- **Laporan Perkembangan** - Generate laporan untuk orang tua

### Untuk Admin (UI Minimal)

- **Dashboard Admin** - Overview sistem
- **Kelola User** - Manajemen user dan role
- **Kelola Pembayaran** - Monitor transaksi
- **Kelola Aset** - Upload konten dan materi
- **Laporan Sistem** - Analytics dan reporting

## 🏗️ Arsitektur

Aplikasi menggunakan **Clean Architecture** dengan pembagian:

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── utils/              # Helper functions & validators
│   ├── services/           # API, Storage, Midtrans services
│   ├── models/             # Data models
│   └── router/             # App routing
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   ├── anak/               # Child data management
│   ├── konsultasi/         # Consultation
│   ├── diagnosa/           # Diagnosis results
│   ├── terapi/             # Therapy sessions
│   ├── pembayaran/         # Payment integration
│   ├── game/               # Therapy games
│   ├── edukasi/            # Educational content
│   ├── laporan/            # Reports
│   └── notifikasi/         # Notifications
├── shared/                 # Shared components
│   ├── widgets/            # Reusable widgets
│   └── themes/             # App themes
├── app.dart               # Main app widget
└── main.dart              # Entry point
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.10.7+
- **State Management**: Riverpod 2.4.9
- **Navigation**: GoRouter 12.1.3
- **HTTP Client**: Dio 5.4.0
- **Local Storage**: SharedPreferences 2.2.2
- **Audio Recording**: Record 5.0.4
- **Audio Playback**: AudioPlayers 5.2.1
- **Image Picker**: Image Picker 1.0.4
- **Payment Gateway**: Midtrans (WebView Flutter 4.4.2)
- **Utils**: Intl 0.19.0, UUID 4.2.1

## 📱 Halaman Utama

### Authentication

- ✅ Splash Screen dengan animasi
- ✅ Login Page dengan validasi
- ✅ Register Page dengan role selection

### Dashboard & Navigation

- ✅ Dashboard Orang Tua dengan quick actions
- ✅ Dashboard Terapis (placeholder)
- ✅ Dashboard Admin (placeholder)

### Data Anak

- ✅ List Anak dengan CRUD operations
- ✅ Add Anak dengan form lengkap
- 🚧 Edit Anak (placeholder)
- 🚧 Detail Anak (placeholder)

### Konsultasi & Diagnosa

- ✅ Konsultasi Page dengan assessment
- 🚧 Hasil Diagnosa (placeholder)

### Terapi & Game

- ✅ Game Menu dengan berbagai pilihan
- ✅ Voice Practice dengan audio recording
- 🚧 Game lainnya (placeholder)

### Pembayaran

- ✅ Payment Summary Page
- ✅ Payment Page dengan Midtrans Snap
- ✅ Riwayat Pembayaran

## 🔧 Setup & Installation

### Prerequisites

- Flutter SDK 3.10.7+
- Dart SDK
- Android Studio / VS Code
- Android/iOS device atau emulator

### Installation Steps

1. **Clone Repository**

   ```bash
   git clone <repository-url>
   cd deteksi_telat_bicara
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Setup Midtrans**
   - Daftar di [Midtrans](https://midtrans.com)
   - Dapatkan Client Key dan Server Key
   - Update di `lib/core/constants/app_constants.dart`:

   ```dart
   static const String midtransClientKey = 'YOUR_CLIENT_KEY';
   static const String midtransServerKey = 'YOUR_SERVER_KEY';
   ```

4. **Setup Assets**

   ```bash
   # Buat folder assets jika belum ada
   mkdir assets/images assets/icons assets/sounds
   ```

5. **Run Application**
   ```bash
   flutter run
   ```

## 🔑 Demo Accounts

Untuk testing, gunakan akun demo berikut:

**Orang Tua:**

- Email: `demo@example.com`
- Password: `123456`

**Terapis:**

- Email: `terapis@example.com`
- Password: `123456`

## 💳 Integrasi Midtrans

Aplikasi terintegrasi dengan Midtrans untuk pembayaran:

### Fitur Pembayaran

- ✅ Create transaction dengan Snap Token
- ✅ Multiple payment methods (Credit Card, Bank Transfer, E-Wallet, QRIS)
- ✅ Payment status tracking
- ✅ Transaction history
- ✅ Payment callbacks handling

### Contoh Penggunaan

```dart
// Create payment
final snapToken = await MidtransService().createTransaction(
  orderId: 'ORDER-123',
  grossAmount: 150000,
  customerDetails: customerData,
);

// Open payment page
Navigator.push(context, MaterialPageRoute(
  builder: (context) => PaymentPage(
    orderId: orderId,
    amount: amount,
    customerDetails: customerDetails,
  ),
));
```

## 🎮 Game Terapi

### Voice Practice Game

- ✅ Audio recording dengan permission handling
- ✅ Playback recorded audio
- ✅ Progress tracking dengan scoring
- ✅ Multiple practice words
- ✅ Visual feedback dengan animasi

### Game Lainnya (Dalam Pengembangan)

- 🚧 Menirukan Suara
- 🚧 Tebak Gambar
- 🚧 Puzzle Kata

## 📊 State Management

Menggunakan Riverpod untuk state management:

### Auth Provider

```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ApiService());
});
```

### Anak Provider

```dart
final anakProvider = StateNotifierProvider<AnakNotifier, AnakState>((ref) {
  return AnakNotifier(ApiService());
});
```

## 🎨 UI/UX Design

### Theme System

- Material Design 3
- Custom color scheme
- Consistent typography
- Responsive design

### Custom Widgets

- `CustomButton` - Reusable button dengan loading state
- `CustomTextField` - Input field dengan validasi
- `LoadingWidget` - Loading indicators
- `EmptyStateWidget` - Empty state handling

## 🔒 Security & Permissions

### Required Permissions

- **Microphone** - Untuk recording suara
- **Storage** - Untuk menyimpan file audio
- **Internet** - Untuk API calls dan pembayaran
- **Camera** - Untuk upload foto (opsional)

### Data Security

- Token-based authentication
- Secure storage dengan SharedPreferences
- Input validation dan sanitization
- Error handling yang proper

## 🚀 Deployment

### Android

```bash
flutter build apk --release
# atau
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 🧪 Testing

### Demo Akun

Gunakan email `demo@example.com` dan password `123456` untuk testing.

### Mock Data

Aplikasi menggunakan mock data untuk development. Ganti dengan API calls yang sebenarnya untuk production.

## 📝 TODO & Roadmap

### High Priority

- [ ] Implementasi API backend yang sebenarnya
- [ ] Complete game implementations
- [ ] Push notifications
- [ ] Offline mode support

### Medium Priority

- [ ] Dark theme support
- [ ] Multi-language support
- [ ] Advanced analytics
- [ ] Export reports to PDF

### Low Priority

- [ ] Social sharing features
- [ ] Community features
- [ ] Advanced customization

## 🤝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Developer**: [Your Name]
- **UI/UX Designer**: [Designer Name]
- **Project Manager**: [PM Name]

## 📞 Support

Untuk pertanyaan atau dukungan:

- Email: support@speechtherapy.com
- WhatsApp: +62 812-3456-7890

---

**Speech Therapy App** - Membantu anak-anak Indonesia mengatasi speech delay dengan teknologi modern dan pendekatan yang menyenangkan! 🎯✨
