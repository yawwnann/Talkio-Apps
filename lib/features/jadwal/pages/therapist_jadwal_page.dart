import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/jadwal_model.dart';
import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../providers/jadwal_provider.dart';

class TherapistJadwalPage extends ConsumerStatefulWidget {
  const TherapistJadwalPage({super.key});

  @override
  ConsumerState<TherapistJadwalPage> createState() =>
      _TherapistJadwalPageState();
}

class _TherapistJadwalPageState extends ConsumerState<TherapistJadwalPage> {
  int _selectedDateIndex = 1;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, String>> _dates = [];

  @override
  void initState() {
    super.initState();
    _generateDates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jadwalProvider.notifier).fetchJadwal();
    });
  }

  void _generateDates() {
    _dates = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate 7 days starting from today
    for (int i = 0; i <= 6; i++) {
      final date = today.add(Duration(days: i));
      final dayName = [
        'SEN',
        'SEL',
        'RAB',
        'KAM',
        'JUM',
        'SAB',
        'MIN',
      ][date.weekday - 1];
      _dates.add({
        'day': dayName,
        'date': date.day.toString(),
        'fullDate': date.toIso8601String(), // This will now be at 00:00:00 local time
      });
    }

    // Set selected index to today (index 0)
    _selectedDateIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final jadwalState = ref.watch(jadwalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: CustomAppBar(
        title: 'Jadwal',
        showBackButton: false,
        showLogo: true,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22, color: AppConstants.primaryBlue),
            onPressed: () {
              ref.read(jadwalProvider.notifier).fetchJadwal(
                    startDate: _selectedDate.toIso8601String(),
                    endDate: _selectedDate
                        .add(const Duration(days: 1))
                        .toIso8601String(),
                  );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthAndSlider(),
            const SizedBox(height: 32),
            _buildAgendaHeader(),
            const SizedBox(height: 24),
            _buildAgendaTimeline(jadwalState),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: TherapistBottomNav(
        currentIndex: 2,
      ), // Index 2 is Jadwal
    );
  }

  Widget _buildMonthAndSlider() {
    final now = DateTime.now();
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final monthName = monthNames[now.month - 1];
    final year = now.year;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$monthName $year',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      // Refresh schedule for selected date
                      ref
                          .read(jadwalProvider.notifier)
                          .fetchJadwal(
                            startDate: picked.toIso8601String(),
                            endDate: picked
                                .add(const Duration(days: 1))
                                .toIso8601String(),
                          );
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: AppConstants.primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pilih Tanggal',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_dates.length, (index) {
                final isSelected = _selectedDateIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDateIndex = index;
                      final selectedIsoDate = _dates[index]['fullDate']!;
                      final dateObj = DateTime.parse(selectedIsoDate);
                      _selectedDate = dateObj;
                      ref.read(jadwalProvider.notifier).fetchJadwal(
                            startDate: selectedIsoDate,
                            endDate: dateObj.add(const Duration(days: 1)).toIso8601String(),
                          );
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 60,
                    height: 85,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppConstants.primaryBlue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppConstants.primaryBlue
                            : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppConstants.primaryBlue.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dates[index]['day']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _dates[index]['date']!,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Agenda Anda',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppConstants.primaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  'Hari Ini',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaTimeline(JadwalState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // NOTE: Jangan sembunyikan jadwal yang sudah lewat waktunya.
    // Terapis tetap perlu melihat sesi yang sudah selesai waktunya untuk melakukan konfirmasi selesai.
    final validSchedules = [...state.jadwalList]
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    if (validSchedules.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_available_rounded, size: 48, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum Ada Jadwal',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda tidak memiliki sesi terapi pada tanggal ini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Build timeline from real data
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: validSchedules.asMap().entries.map((entry) {
          final index = entry.key;
          final schedule = entry.value;
          final isFirst = index == 0;
          final isLast = index == validSchedules.length - 1;
          final status = schedule.status.toUpperCase();

          String statusType;
          switch (status) {
            case 'COMPLETED':
              statusType = 'completed';
              break;
            case 'ONGOING':
              statusType = 'ongoing';
              break;
            case 'PENDING_CONFIRMATION':
              statusType = 'pending_confirmation';
              break;
            case 'CANCELLED':
              statusType = 'cancelled';
              break;
            default:
              statusType = 'scheduled';
          }

          return _buildTimelineItem(
            statusType: statusType,
            isFirst: isFirst,
            isLast: isLast,
            child: _buildScheduleCardFromModel(
              schedule: schedule,
              statusType: statusType,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScheduleCardFromModel({
    required JadwalModel schedule,
    required String statusType,
  }) {
    final therapyType = schedule.sessionType ?? 'Terapi Bicara';
    final time = schedule.timeSlot;
    final isOnline =
        therapyType.toLowerCase().contains('online') ||
        schedule.meetingLink != null;

    // Get child name from model
    final childName = schedule.childName ?? 'Pasien';

    if (statusType == 'completed') {
      return _buildCompletedCard(
        schedule.anakId,
        time,
        childName,
        '$therapyType • ${isOnline ? "Online" : "Offline"}',
      );
    } else if (statusType == 'ongoing') {
      return _buildOngoingCard(
        schedule.anakId,
        schedule.id,
        time,
        childName,
        '$therapyType • ${isOnline ? "Online" : "Offline"}',
      );
    } else if (statusType == 'pending_confirmation') {
      return _buildPendingConfirmationCard(
        schedule.anakId,
        schedule.id,
        schedule.status,
        time,
        childName,
        '$therapyType • ${isOnline ? "Online" : "Offline"}',
      );
    } else {
      return _buildConfirmedCard(
        schedule.anakId,
        schedule.id,
        schedule.status,
        time,
        childName,
        '$therapyType • ${isOnline ? "Online" : "Offline"}',
      );
    }
  }

  Widget _buildTimelineItem({
    required String statusType,
    required bool isFirst,
    required bool isLast,
    required Widget child,
  }) {
    Color nodeColor;
    Widget icon;

    if (statusType == 'completed') {
      nodeColor = const Color(0xFF86EFAC); // Light Green
      icon = const Icon(
        Icons.check,
        size: 14,
        color: Color(0xFF14532D),
      ); // Dark Green
    } else if (statusType == 'ongoing') {
      nodeColor = Colors.white;
      icon = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppConstants.primaryBlue,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.play_arrow, size: 12, color: Colors.white),
      );
    } else if (statusType == 'empty') {
      nodeColor = const Color(0xFFE5E7EB); // Light Grey
      icon = const Icon(Icons.add, size: 14, color: Color(0xFF6B7280));
    } else {
      // scheduled format
      nodeColor = Colors.white;
      icon = const Icon(
        Icons.access_time_filled,
        size: 18,
        color: Color(0xFF6B7280),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Node and Line
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top line
                if (!isFirst)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFE5E7EB),
                      // Ideally dashed line for empty, but solid line works as MVP
                    ),
                  ),
                // Center dot
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: statusType == 'ongoing' ? 32 : 28,
                    height: statusType == 'ongoing' ? 32 : 28,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                      border: statusType == 'ongoing'
                          ? Border.all(
                              color: AppConstants.primaryBlue,
                              width: 1.5,
                            )
                          : statusType == 'scheduled' || statusType == 'empty'
                          ? Border.all(color: const Color(0xFFE5E7EB), width: 1)
                          : null,
                    ),
                    child: Center(child: icon),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  // Card 1: Completed
  Widget _buildCompletedCard(String anakId, String time, String name, String subtitle) {
    return GestureDetector(
      onTap: () => context.push('/therapist/pasien/$anakId'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'COMPLETED',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.push('/therapist/pasien/$anakId'),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF0F6FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Lihat Detail',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // Card 2: Ongoing
  Widget _buildOngoingCard(String anakId, String id, String time, String name, String subtitle) {
    return GestureDetector(
      onTap: () => context.push('/therapist/pasien/$anakId'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border(
          left: BorderSide(color: AppConstants.primaryBlue, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Sedang Berlangsung',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    'Mulai',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(jadwalProvider.notifier).completeJadwal(id).then((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sesi terapi berhasil diselesaikan'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }).catchError((error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menyelesaikan sesi: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Selesaikan Sesi',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Icon(
                    Icons.videocam,
                    color: Color(0xFF4B5563),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  // Card 3: Empty Slot
  Widget _buildEmptySlotCard(String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.5,
          style: BorderStyle.solid,
        ), // Dashed normally needs a package, using solid border with high radius
      ),
      // To simulate dashed in highly visual component we could use flutter_dash but assuming standard widgets:
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Belum ada jadwal terdaftar',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 18, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  // Card 4: Confirmed (Scheduled)
  Widget _buildConfirmedCard(
    String anakId,
    String scheduleId,
    String status,
    String time,
    String name,
    String subtitle,
  ) {
    return GestureDetector(
      onTap: () => context.push('/therapist/pasien/$anakId'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'CONFIRMED',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => context.push('/therapist/pasien/$anakId'),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    foregroundColor: const Color(0xFF1F2937),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Pasien',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showScheduleDetail(
                    scheduleId: scheduleId,
                    anakId: anakId,
                    time: time,
                    name: name,
                    subtitle: subtitle,
                    status: status,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    foregroundColor: const Color(0xFF1F2937),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Detail',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  // Card 5: Pending Confirmation (session ended, needs therapist confirmation)
  Widget _buildPendingConfirmationCard(
    String anakId,
    String scheduleId,
    String status,
    String time,
    String name,
    String subtitle,
  ) {
    return GestureDetector(
      onTap: () => context.push('/therapist/pasien/$anakId'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            left: BorderSide(color: Color(0xFFF59E0B), width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Text(
                    'PERLU KONFIRMASI',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.push('/therapist/pasien/$anakId'),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: const Color(0xFF1F2937),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Pasien',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showScheduleDetail(
                      scheduleId: scheduleId,
                      anakId: anakId,
                      time: time,
                      name: name,
                      subtitle: subtitle,
                      status: status,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: const Color(0xFF1F2937),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Detail',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Removed _buildStatistics to clean up the page as requested

  void _showScheduleDetail({
    required String scheduleId,
    required String anakId,
    required String time,
    required String name,
    required String subtitle,
    required String status,
  }) {
    final upperStatus = status.toUpperCase();
    final showComplete =
        upperStatus != 'COMPLETED' && upperStatus != 'CANCELLED';
    final canComplete =
        upperStatus == 'ONGOING' || upperStatus == 'PENDING_CONFIRMATION';

    final statusLabel = switch (upperStatus) {
      'SCHEDULED' => 'Terjadwal',
      'ONGOING' => 'Sedang berlangsung',
      'PENDING_CONFIRMATION' => 'Menunggu konfirmasi selesai',
      'COMPLETED' => 'Selesai',
      'CANCELLED' => 'Batal',
      _ => upperStatus,
    };

    final recordButtonBg =
        canComplete ? const Color(0xFFF3F4F6) : AppConstants.primaryBlue;
    final recordButtonFg =
        canComplete ? AppConstants.primaryBlue : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
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
            Text(
              'Detail Jadwal',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.person, 'Pasien', name),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.access_time, 'Waktu', time),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.category, 'Jenis Terapi', subtitle),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.info_outline, 'Status', statusLabel),
            const SizedBox(height: 24),
            if (showComplete)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canComplete
                      ? () async {
                          try {
                            await ref
                                .read(jadwalProvider.notifier)
                                .completeJadwal(scheduleId);

                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Sesi berhasil dikonfirmasi selesai',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal konfirmasi selesai: $e',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Konfirmasi Selesai',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (showComplete && !canComplete)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tombol aktif saat sesi sedang berlangsung atau sudah lewat waktunya.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            if (showComplete) const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/therapist/pasien/$anakId');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: recordButtonBg,
                  foregroundColor: recordButtonFg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Lihat Rekam Medis',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: recordButtonFg,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF4B5563)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateScheduleDialog() async {
    // TODO: Implement create schedule dialog
    // This should open a dialog/form to create new schedule
    // and call createSchedule() API from api_service.dart
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Buat Jadwal Baru',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // TODO: Add form fields for:
              // - Select patient
              // - Date & time picker
              // - Therapy type dropdown
              // - Session type (Online/Offline)
              const Text('Form create schedule akan ditambahkan di sini'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Call createSchedule API
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Simpan Jadwal'),
              ),
            ],
          ),
        );
      },
    );
  }
}
