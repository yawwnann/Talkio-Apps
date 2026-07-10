Berdasarkan flowchart dan daftar peran (*User Roles*) yang kamu lampirkan, saya telah menyusun **Product Requirement Document (PRD)** yang difokuskan untuk pengembangan frontend menggunakan **Flutter**.

PRD ini dirancang untuk memastikan navigasi dan state management di Flutter sesuai dengan alur sistem deteksi keterlambatan bicara anak yang sedang kamu bangun.

---

# Product Requirement Document (PRD) - Aplikasi Deteksi Speech Delay

## 1. Ringkasan Proyek
Aplikasi mobile berbasis Flutter yang berfungsi sebagai platform deteksi dini keterlambatan bicara pada anak, media terapi mandiri (game), serta penghubung antara orang tua, terapis, dan admin.

---

## 2. Arsitektur Role & Autentikasi
Aplikasi ini menggunakan **Role-Based Access Control (RBAC)**.
* **Orang Tua:** User publik (bisa registrasi).
* **Terapis & Admin:** User internal (login dengan akun yang sudah disediakan/dikelola admin).

---

## 3. Spesifikasi Fitur Utama (Frontend)

### A. Fitur Orang Tua (Parent Module)
| Fitur | Deskripsi UI/UX | Alur Flowchart |
| :--- | :--- | :--- |
| **Auth & Profile** | Screen Registrasi & Login. Input data anak (Nama, Umur, Jenis Kelamin). | Start -> Registrasi/Login -> Kelola Data Anak |
| **Konsultasi & Diagnosa** | Form input gejala (Checkbox/Radio). Output: Hasil risiko (Rendah/Tinggi). | Pilih Menu -> Konsultasi -> Tampilkan Hasil Risiko |
| **Terapi Game** | Interface game interaktif untuk anak. Menyimpan skor/progres secara otomatis. | Pilih Menu -> Main Game Terapi -> Simpan Hasil Game |
| **Booking & Payment** | Katalog jadwal terapis, integrasi payment gateway (tampil biaya 165.000). | Pilih Menu -> Booking -> Proses Pembayaran -> Status |
| **Edukasi & Monitoring** | List artikel/video. View riwayat perkembangan & laporan dari terapis. | Pilih Menu -> Lihat Edukasi / Lihat Riwayat |

### B. Fitur Terapis (Therapist Module)
| Fitur | Deskripsi UI/UX | Alur Flowchart |
| :--- | :--- | :--- |
| **Dashboard Terapis** | Overview jadwal hari ini dan daftar pasien (anak) yang ditangani. | Login -> Dashboard Terapis |
| **Monitoring Pasien** | View detail data anak, hasil diagnosa awal, dan hasil latihan suara dari game. | Pilih Menu -> Lihat Data / Hasil Diagnosa / Latihan Suara |
| **Evaluasi & Laporan** | Form input evaluasi perkembangan. Button "Generate Laporan" (PDF/View). | Monitoring -> Evaluasi -> Generate Laporan |

### C. Fitur Admin (Admin Panel - Mobile/Web)
| Fitur | Deskripsi UI/UX | Alur Flowchart |
| :--- | :--- | :--- |
| **Manajemen User** | CRUD data pengguna (Orang tua & Terapis). | Kelola Data Pengguna |
| **Manajemen Operasional** | Kelola jadwal terapis, verifikasi pembayaran, dan aset alat terapi. | Kelola Jadwal / Pembayaran / Aset |
| **Konten & Sistem** | Update materi edukasi, kelola testimoni, dan generate laporan sistem global. | Kelola Edukasi / Testimoni / Generate Laporan |

---

## 4. Requirement Teknis (Flutter)

### Struktur Navigasi
* **Root:** `ConditionalRoute` berdasarkan status login dan role.
* **Parent:** `BottomNavigationBar` (Home, Game, History, Profile).
* **Therapist/Admin:** `NavigationRail` atau `Drawer` untuk akses menu manajemen yang padat.

### State Management & Data
* **State Management:** Disarankan menggunakan **Provider** atau **Bloc** untuk menghandle status pembayaran (Pending/Berhasil) dan progres game secara real-time.
* **Storage:** `Shared Preferences` untuk session login dan `Firebase Cloud Messaging (FCM)` untuk notifikasi jadwal terapi.

---

## 5. Rencana Antarmuka (UI Design)
Berdasarkan preferensi desainmu yang bersih dan minimalis:
* **Palet Warna:** Putih sebagai background utama, **Orange/Red** sebagai *primary action button*, dan **Hitam** untuk tipografi.
* **Tipografi:** Gunakan font yang ramah anak namun tetap profesional untuk orang tua (contoh: *Poppins* atau *Nunito*).

---

## 6. Roadmap Pengembangan Frontend
1.  **Sprint 1:** Setup Project, Auth UI, dan Integrasi Database (Firebase/API).
2.  **Sprint 2:** Pengembangan Modul Orang Tua (Form Diagnosa & Game Sederhana).
3.  **Sprint 3:** Pengembangan Modul Terapis & Admin (Data Grid & Reporting).
4.  **Sprint 4:** Integrasi Payment Gateway & Sistem Notifikasi.

**Apakah kamu ingin saya membantu membuatkan boilerplate kode Flutter untuk struktur navigasi berdasarkan 3 role di atas?**