import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';

class JadwalTerapiPage extends ConsumerStatefulWidget {
  const JadwalTerapiPage({super.key});

  @override
  ConsumerState<JadwalTerapiPage> createState() => _JadwalTerapiPageState();
}

class _JadwalTerapiPageState extends ConsumerState<JadwalTerapiPage> {
  int _selectedWeekDay = 0; // 0 = today

  // Mock data for sessions
  final List<Map<String, dynamic>> _sessions = [
    {
      'time': '09:00',
      'endTime': '10:00',
      'patientName': 'Siti Nurhaliza',
      'therapyType': 'Terapi Bicara',
      'status': 'completed',
      'patientId': '1',
    },
    {
      'time': '11:00',
      'endTime': '12:00',
      'patientName': 'Ahmad Fauzi',
      'therapyType': 'Terapi Wicara',
      'status': 'ongoing',
      'patientId': '2',
    },
    {
      'time': '14:00',
      'endTime': '15:00',
      'patientName': 'Dewi Lestari',
      'therapyType': 'Konsultasi',
      'status': 'upcoming',
      'patientId': '3',
    },
  ];

  List<DateTime> _getWeekDates() {
    final today = DateTime.now();
    final weekday = today.weekday;
    final monday = today.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();
    final completedCount = _sessions.where((s) => s['status'] == 'completed').length;
    final ongoingCount = _sessions.where((s) => s['status'] == 'ongoing').length;
    final upcomingCount = _sessions.where((s) => s['status'] == 'upcoming').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildDateStrip(weekDates),
          _buildStatsRow(completedCount, ongoingCount, upcomingCount),
          Expanded(
            child: _buildTimeline(),
          ),
        ],
      ),
      bottomNavigationBar: TherapistBottomNav(currentIndex: 2),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final now = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(now);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.calendar_month_outlined, size: 22, color: Color(0xFF111827)),
        onPressed: () {},
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jadwal Terapi',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              fontSize: 16,
            ),
          ),
          Text(
            monthYear,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 22, color: AppConstants.primaryBlue),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Jadwal berhasil diperbarui'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppConstants.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_alt_outlined, size: 20, color: AppConstants.primaryBlue),
            onPressed: () {},
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppConstants.primaryBlue, AppConstants.lightBlue],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateStrip(List<DateTime> weekDates) {
    final today = DateTime.now();
    // Nama hari Indonesia - mapping dari weekday number
    final dayNames = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      height: 68,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isToday = date.day == today.day && date.month == today.month;
          final isSelected = index == _selectedWeekDay;
          // Gunakan weekday dari date object (1=Sen...7=Min)
          final dayName = dayNames[date.weekday];

          return GestureDetector(
            onTap: () => setState(() => _selectedWeekDay = index),
            child: Container(
              width: 40,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppConstants.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppConstants.primaryBlue.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isToday && !isSelected
                          ? AppConstants.primaryBlue.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? AppConstants.primaryBlue
                                  : const Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(int completed, int ongoing, int upcoming) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatChip('Selesai', completed, const Color(0xFF10B981)),
            const SizedBox(width: 8),
            _buildStatChip('Berlangsung', ongoing, const Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            _buildStatChip('Menunggu', upcoming, const Color(0xFFF59E0B)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        final isLast = index == _sessions.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0) const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    session['time'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildSessionCard(session, isLast),
                ),
              ],
            ),
            if (!isLast) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, bool isLast) {
    final status = session['status'];
    final isCompleted = status == 'completed';
    final isOngoing = status == 'ongoing';
    final isUpcoming = status == 'upcoming';

    Color statusColor;
    Color bgColor;
    String statusText;

    if (isCompleted) {
      statusColor = const Color(0xFF10B981);
      bgColor = const Color(0xFF10B981).withValues(alpha: 0.05);
      statusText = 'Selesai';
    } else if (isOngoing) {
      statusColor = const Color(0xFF3B82F6);
      bgColor = const Color(0xFF3B82F6).withValues(alpha: 0.1);
      statusText = 'Berlangsung';
    } else {
      statusColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.05);
      statusText = 'Menunggu';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOngoing ? statusColor : const Color(0xFFE5E7EB),
          width: isOngoing ? 1.5 : 1,
        ),
        boxShadow: isOngoing
            ? [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isOngoing)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (isOngoing) const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${session['time']} - ${session['endTime']}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ProfileAvatar(
                name: session['patientName'],
                radius: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['patientName'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      session['therapyType'],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              if (isOngoing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Mulai',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isUpcoming)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Detail',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Laporan',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
