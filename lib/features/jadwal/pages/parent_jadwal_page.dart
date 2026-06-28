import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/parent_schedule_provider.dart';
import '../../../shared/widgets/parent_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../../shared/widgets/loading_widget.dart';

class ParentJadwalPage extends ConsumerStatefulWidget {
  const ParentJadwalPage({super.key});

  @override
  ConsumerState<ParentJadwalPage> createState() => _ParentJadwalPageState();
}

class _ParentJadwalPageState extends ConsumerState<ParentJadwalPage> {
  int _selectedWeekDay = 0;
  String _selectedFilter = 'all'; // 'all', 'active', 'pending', 'completed'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(parentScheduleProvider.notifier).fetchSchedule();
    });
  }

  List<DateTime> _getWeekDates() {
    final today = DateTime.now();
    return List.generate(30, (index) => today.add(Duration(days: index)));
  }

  /// Get sessions for the selected day
  List<Map<String, dynamic>> _getSelectedDaySessions(List<Map<String, dynamic>> sessions) {
    final weekDates = _getWeekDates();
    final selectedDate = weekDates[_selectedWeekDay];

    return sessions.where((session) {
      try {
        final scheduleDate = DateTime.parse(session['schedule']);
        return scheduleDate.year == selectedDate.year &&
            scheduleDate.month == selectedDate.month &&
            scheduleDate.day == selectedDate.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Get sessions filtered by status
  List<Map<String, dynamic>> _getFilteredSessions(List<Map<String, dynamic>> allSessions) {
    switch (_selectedFilter) {
      case 'active':
        return allSessions.where((s) => s['isActive'] == true && s['paymentStatus'] == 'SUCCESS').toList();
      case 'pending':
        return allSessions.where((s) => s['paymentStatus'] == 'PENDING').toList();
      case 'completed':
        return allSessions.where((s) => s['isActive'] == false && s['paymentStatus'] == 'SUCCESS').toList();
      default:
        return allSessions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();
    final scheduleState = ref.watch(parentScheduleProvider);
    final allSessions = scheduleState.scheduleList;

    // Filter sessions by selected day AND status filter
    List<Map<String, dynamic>> daySessions = _getSelectedDaySessions(allSessions);
    List<Map<String, dynamic>> filteredSessions = _getFilteredSessions(daySessions);

    // Calculate stats from ALL sessions (not just selected day)
    final activeCount = allSessions.where((s) => s['isActive'] == true && s['paymentStatus'] == 'SUCCESS').length;
    final pendingCount = allSessions.where((s) => s['paymentStatus'] == 'PENDING').length;
    final completedCount = allSessions.where((s) => s['isActive'] == false && s['paymentStatus'] == 'SUCCESS').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterTabs(activeCount, pendingCount, completedCount),
          Expanded(
            child: scheduleState.isLoading
                ? const Center(child: LoadingWidget())
                : scheduleState.error != null
                    ? _buildErrorState(scheduleState.error!)
                    : filteredSessions.isEmpty
                        ? _buildEmptyState()
                        : _buildScheduleList(filteredSessions),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/booking/therapist'),
        backgroundColor: AppConstants.primaryBlue,
        icon: const Icon(Icons.add_circle, color: Colors.white, size: 20),
        label: Text(
          'Booking Terapi',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: const ParentBottomNav(currentIndex: 3),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final now = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(now);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
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
          icon: const Icon(Icons.refresh, size: 22),
          onPressed: () => ref.read(parentScheduleProvider.notifier).fetchSchedule(),
        ),
        const SizedBox(width: 8),
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
        itemCount: weekDates.length,
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

  Widget _buildFilterTabs(int active, int pending, int completed) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Semua', 'all', active + pending + completed, AppConstants.primaryBlue),
            const SizedBox(width: 8),
            _buildFilterChip('Aktif', 'active', active, const Color(0xFF10B981)),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending', pending, const Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            _buildFilterChip('Selesai', 'completed', completed, const Color(0xFF3B82F6)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter, int count, Color color) {
    final isSelected = _selectedFilter == filter;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          '$count $label',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? color : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleList(List<Map<String, dynamic>> sessions) {
    // Group sessions by child name
    final groupedSessions = <String, List<Map<String, dynamic>>>{};
    for (final session in sessions) {
      final childName = session['childName'] ?? 'Tidak Diketahui';
      groupedSessions.putIfAbsent(childName, () => []).add(session);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(parentScheduleProvider.notifier).fetchSchedule(),
      color: AppConstants.primaryBlue,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: groupedSessions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final childName = groupedSessions.keys.elementAt(index);
          final childSessions = groupedSessions[childName]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Child header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        childName.isNotEmpty ? childName[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          childName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          '${childSessions.length} jadwal',
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...childSessions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildSessionCard(s),
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final isActive = session['isActive'] == true;
    final paymentStatus = session['paymentStatus'];
    final sessionId = session['id']?.toString() ?? '';

    // Parse schedule date
    DateTime scheduleDate;
    try {
      scheduleDate = DateTime.parse(session['schedule']).toLocal();
    } catch (e) {
      scheduleDate = DateTime.now();
    }

    // Check if session has passed (add 30 minutes tolerance)
    final now = DateTime.now();
    final sessionExpired = scheduleDate.add(const Duration(minutes: 30)).isBefore(now);

    // Determine status
    Color statusColor;
    String statusLabel;
    bool showPayButton = false;

    if (paymentStatus == 'PENDING') {
      if (sessionExpired) {
        // Session has passed - show as cancelled/expired
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'Terlewat';
        showPayButton = false;
      } else {
        // Session hasn't passed yet - show pending with pay button
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Menunggu Pembayaran';
        showPayButton = true;
      }
    } else if (isActive) {
      statusColor = const Color(0xFF10B981);
      statusLabel = 'Aktif';
      showPayButton = false;
    } else {
      statusColor = const Color(0xFF3B82F6);
      statusLabel = 'Selesai';
      showPayButton = false;
    }

    final timeStr = DateFormat('HH:mm').format(scheduleDate);
    final dateStr = DateFormat('dd MMM yyyy').format(scheduleDate);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? statusColor : const Color(0xFFE5E7EB),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
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
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                dateStr,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ProfileAvatar(
                name: session['childName'],
                radius: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['childName'] ?? '-',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      session['therapyType'] ?? '-',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: const Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(
                timeStr,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.person_outline, size: 14, color: const Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  session['therapistName'] ?? 'Belum ditugaskan',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Action buttons
          if (showPayButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handlePayNow(session),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.payment, size: 18),
                label: Text(
                  'Bayar Sekarang',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          // Show cancel message if session expired
          if (paymentStatus == 'PENDING' && sessionExpired) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: const Color(0xFFEF4444)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Waktu pembayaran telah habis. Sesi tidak dapat diproses.',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handlePayNow(Map<String, dynamic> session) async {
    final sessionId = session['id']?.toString();
    if (sessionId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID sesi tidak valid'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      final result = await ref.read(parentScheduleProvider.notifier).retakePayment(sessionId);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      if (result != null) {
        final paymentUrl = result['paymentUrl']?.toString();

        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          if (mounted) {
            final paymentResult = await context.push<bool>('/payment/webview', extra: {
              'paymentUrl': paymentUrl,
              'sessionId': sessionId,
            });

            if (paymentResult == true && mounted) {
              // Refresh schedule after successful payment
              ref.read(parentScheduleProvider.notifier).fetchSchedule();
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('URL pembayaran tidak tersedia'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mendapatkan URL pembayaran'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: const Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat jadwal',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(parentScheduleProvider.notifier).fetchSchedule(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Coba Lagi', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text(
            'Belum ada jadwal',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jadwal akan muncul setelah pembayaran dikonfirmasi',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
 
        ],
      ),
    );
  }
}
