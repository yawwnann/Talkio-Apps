import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/jadwal_model.dart';
import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../providers/jadwal_provider.dart';

class TherapistJadwalPage extends ConsumerStatefulWidget {
  const TherapistJadwalPage({super.key});

  @override
  ConsumerState<TherapistJadwalPage> createState() => _TherapistJadwalPageState();
}

class _TherapistJadwalPageState extends ConsumerState<TherapistJadwalPage> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jadwalProvider.notifier).fetchJadwal();
    });
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jadwalProvider);
    final all = state.jadwalList;

    final filtered = _filtered(all);
    final sched = all.where((s) => s.status == 'SCHEDULED').length;
    final ongoing = all.where((s) => s.status == 'ONGOING').length;
    final done = all.where((s) =>
        s.status == 'COMPLETED' || s.status == 'CANCELLED').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _appBar(),
      body: Column(children: [
        _filterTabs(sched, ongoing, done),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? _emptyState()
                  : _list(filtered),
        ),
      ]),
      bottomNavigationBar: const TherapistBottomNav(currentIndex: 2),
    );
  }

  List<JadwalModel> _filtered(List<JadwalModel> sessions) {
    switch (_filter) {
      case 'ongoing':
        return sessions.where((s) => s.status == 'ONGOING').toList();
      case 'scheduled':
        return sessions.where((s) => s.status == 'SCHEDULED').toList();
      case 'completed':
        return sessions
            .where((s) => s.status == 'COMPLETED' || s.status == 'CANCELLED')
            .toList();
      default:
        return sessions;
    }
  }

  PreferredSizeWidget _appBar() {
    final month = DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jadwal Terapi', style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          )),
          Text(month, style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF6B7280),
          )),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppConstants.primaryBlue),
          onPressed: () {
            ref.read(jadwalProvider.notifier).fetchJadwal();
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppConstants.primaryBlue, AppConstants.lightBlue],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterTabs(int sched, int ongoing, int done) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('Semua', 'all', sched + ongoing + done, AppConstants.primaryBlue),
            const SizedBox(width: 8),
            _chip('Terjadwal', 'scheduled', sched, const Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            _chip('Berlangsung', 'ongoing', ongoing, const Color(0xFF10B981)),
            const SizedBox(width: 8),
            _chip('Selesai', 'completed', done, const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String filter, int count, Color color) {
    final sel = _filter == filter;
    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: sel ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Text(
          '$count $label',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
            color: sel ? color : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _list(List<JadwalModel> sessions) {
    final grouped = <String, List<JadwalModel>>{};
    for (final s in sessions) {
      final name = s.childName ?? 'Tidak Diketahui';
      grouped.putIfAbsent(name, () => []).add(s);
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(jadwalProvider.notifier).fetchJadwal(),
      color: AppConstants.primaryBlue,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: grouped.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (ctx, i) {
          final name = grouped.keys.elementAt(i);
          final list = grouped[name]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                ProfileAvatar(name: name, radius: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    )),
                    Text('${list.length} jadwal', style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    )),
                  ]),
                ),
              ]),
              const SizedBox(height: 8),
              ...list.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _card(s),
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _card(JadwalModel s) {
    final status = s.status.toUpperCase();
    final schedDate = s.scheduledDate;
    final endTime = schedDate.add(const Duration(hours: 1));
    final deadline = endTime.add(const Duration(minutes: 30));
    final now = DateTime.now();
    final canComplete = status == 'ONGOING' && now.isBefore(deadline);
    final expired = status == 'ONGOING' && now.isAfter(deadline);

    Color sc; String sl; IconData si;
    switch (status) {
      case 'COMPLETED':
        sc = const Color(0xFF10B981); sl = 'Selesai'; si = Icons.check_circle;
      case 'ONGOING':
        sc = expired ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6);
        sl = expired ? 'Terlewat' : 'Berlangsung';
        si = expired ? Icons.warning_rounded : Icons.play_circle;
      case 'CANCELLED':
        sc = const Color(0xFFEF4444); sl = 'Dibatalkan'; si = Icons.cancel_rounded;
      case 'PENDING_CONFIRMATION':
        sc = const Color(0xFFF59E0B); sl = 'Konfirmasi'; si = Icons.pending_rounded;
      default:
        sc = const Color(0xFF6B7280); sl = 'Terjadwal'; si = Icons.schedule_rounded;
    }

    final active = status == 'ONGOING' || status == 'PENDING_CONFIRMATION';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? sc : const Color(0xFFE5E7EB),
          width: active ? 1.5 : 1,
        ),
        boxShadow: active
            ? [BoxShadow(color: sc.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))]
            : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: sc.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(si, size: 14, color: sc),
              const SizedBox(width: 4),
              Text(sl, style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: sc,
              )),
            ]),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateFormat('dd MMM yyyy').format(schedDate), style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF6B7280),
              )),
              Text(s.timeSlot, style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              )),
            ],
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          ProfileAvatar(name: s.childName ?? '-', radius: 20),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.childName ?? '-', style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            )),
            Text(s.sessionType ?? 'Terapi Wicara', style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6B7280),
            )),
          ])),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _detail(s),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.check_circle_rounded, size: 16),
                const SizedBox(width: 4),
                Text('Konfirmasi', style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _actionBtn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF4B5563)),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4B5563),
            )),
          ],
        ),
      ),
    );
  }

  void _detail(JadwalModel s) {
    final status = s.status.toUpperCase();
    final label = switch (status) {
      'SCHEDULED' => 'Terjadwal',
      'ONGOING' => 'Sedang berlangsung',
      'PENDING_CONFIRMATION' => 'Menunggu konfirmasi',
      'COMPLETED' => 'Selesai',
      'CANCELLED' => 'Batal',
      _ => status,
    };

    final schedDate = s.scheduledDate;
    final now = DateTime.now();
    final sessionStart = schedDate;
    final endTime = schedDate.add(const Duration(hours: 1));
    final deadline = endTime.add(const Duration(minutes: 30));

    // Determine button state based on status and time
    bool isButtonEnabled = false;
    String buttonText = 'Konfirmasi Selesai';
    Color buttonColor = AppConstants.primaryBlue;

    if (status == 'COMPLETED') {
      buttonText = 'Sesi Selesai';
      buttonColor = const Color(0xFF9CA3AF);
      isButtonEnabled = false;
    } else if (status == 'CANCELLED') {
      buttonText = 'Sesi Dibatalkan';
      buttonColor = const Color(0xFF9CA3AF);
      isButtonEnabled = false;
    } else if (status == 'ONGOING') {
      if (now.isAfter(deadline)) {
        buttonText = 'Waktu Habis';
        buttonColor = const Color(0xFF9CA3AF);
        isButtonEnabled = false;
      } else {
        buttonText = 'Konfirmasi Selesai';
        buttonColor = const Color(0xFF10B981);
        isButtonEnabled = true;
      }
    } else if (status == 'PENDING_CONFIRMATION') {
      buttonText = 'Konfirmasi Selesai';
      buttonColor = const Color(0xFF10B981);
      isButtonEnabled = true;
    } else if (status == 'SCHEDULED') {
      if (now.isBefore(sessionStart)) {
        buttonText = 'Belum Waktunya';
        buttonColor = const Color(0xFF9CA3AF);
        isButtonEnabled = false;
      } else {
        buttonText = 'Mulai Sesi';
        buttonColor = const Color(0xFF3B82F6);
        isButtonEnabled = true;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Detail Jadwal', style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 16),
            _dRow(Icons.person, 'Pasien', s.childName ?? '-'),
            const SizedBox(height: 12),
            _dRow(Icons.access_time, 'Waktu', s.timeSlot),
            const SizedBox(height: 12),
            _dRow(Icons.category, 'Jenis Terapi', s.sessionType ?? 'Terapi Wicara'),
            const SizedBox(height: 12),
            _dRow(Icons.info_outline, 'Status', label),
            const SizedBox(height: 24),
            // Tombol Konfirmasi Selesai
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isButtonEnabled ? () {
                  Navigator.pop(ctx);
                  _handleSessionAction(s, status, isButtonEnabled);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isButtonEnabled ? Icons.check_circle : Icons.schedule,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      buttonText,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _dRow(IconData icon, String label, String value) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF4B5563)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(
          fontSize: 12,
          color: const Color(0xFF6B7280),
        )),
        Text(value, style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        )),
      ])),
    ]);
  }

  Future<void> _complete(JadwalModel s) async {
    try {
      await ref.read(jadwalProvider.notifier).completeJadwal(s.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi berhasil dikonfirmasi selesai'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _startSession(JadwalModel s) async {
    try {
      await ref.read(jadwalProvider.notifier).startSession(s.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi dimulai'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleSessionAction(JadwalModel s, String status, bool isEnabled) async {
    if (!isEnabled) return;

    if (status == 'SCHEDULED') {
      // Check if it's time to start
      final now = DateTime.now();
      if (now.isBefore(s.scheduledDate)) {
        // Not yet time - show message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Belum waktunya memulai sesi'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      await _startSession(s);
    } else {
      await _complete(s);
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text('Belum ada jadwal', style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
          )),
          const SizedBox(height: 4),
          Text(
            'Pilih tanggal lain',
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}