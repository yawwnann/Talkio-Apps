import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/anak_model.dart';
import '../../../features/anak/providers/anak_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../../../shared/widgets/parent_bottom_nav.dart';
import '../../../shared/widgets/loading_widget.dart';

class SelectSchedulePage extends ConsumerStatefulWidget {
  final String therapistId;
  final String therapistName;

  const SelectSchedulePage({
    super.key,
    required this.therapistId,
    required this.therapistName,
  });

  @override
  ConsumerState<SelectSchedulePage> createState() => _SelectSchedulePageState();
}

class _SelectSchedulePageState extends ConsumerState<SelectSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  AnakModel? _selectedChild;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChildren();
      _fetchAvailability();
    });
  }

  void _loadChildren() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      ref.read(anakProvider.notifier).getAnakList(user.id);
    }
  }

  void _fetchAvailability() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    ref.read(bookingProvider.notifier).fetchAvailability(widget.therapistId, dateStr);
  }

  List<DateTime> _getWeekDates() {
    final today = DateTime.now();
    final weekday = today.weekday;
    final monday = today.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final anakState = ref.watch(anakProvider);
    final children = anakState.anakList;
    final slots = bookingState.availability?['slots'] as List<dynamic>? ?? [];

    if (_selectedChild == null && children.isNotEmpty) {
      _selectedChild = children.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTherapistInfo(),
            const SizedBox(height: 16),
            _buildChildSelector(children),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 16),
            _buildTimeSlots(slots, bookingState),
            const SizedBox(height: 24),
            _buildBookButton(),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF111827)),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Jadwal',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              fontSize: 16,
            ),
          ),
          Text(
            widget.therapistName,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapistInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppConstants.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medical_services,
              size: 24,
              color: AppConstants.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.therapistName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  'Terapi Bicara & Wicara',
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
    );
  }

  Widget _buildChildSelector(List<AnakModel> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Anak',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        if (children.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Belum ada anak terdaftar',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: children.map((child) {
                final isSelected = _selectedChild?.id == child.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedChild = child),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppConstants.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppConstants.primaryBlue : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      child.name,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final weekDates = _getWeekDates();
    final dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Tanggal',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = weekDates[index];
              final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
                  _fetchAvailability();
                },
                child: Container(
                  width: 44,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppConstants.primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNames[index],
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots(List<dynamic> slots, BookingState bookingState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pilih Jam',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            Row(
              children: [
                _buildLegend('Tersedia', const Color(0xFF10B981)),
                const SizedBox(width: 8),
                _buildLegend('Terisi', const Color(0xFFEF4444)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (bookingState.isLoading && slots.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(32),
            child: LoadingWidget(),
          ))
        else if (slots.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Pilih tanggal untuk melihat jadwal',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) {
                final time = slot['time'];
                final isAvailable = slot['isAvailable'];
                final isSelected = _selectedTimeSlot == time;

                return GestureDetector(
                  onTap: isAvailable
                      ? () => setState(() => _selectedTimeSlot = time)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: !isAvailable
                          ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                          : isSelected
                              ? AppConstants.primaryBlue
                              : const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: !isAvailable
                            ? const Color(0xFFEF4444)
                            : isSelected
                                ? Colors.white
                                : const Color(0xFF10B981),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    final canBook = _selectedChild != null && _selectedTimeSlot != null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canBook
            ? () {
                final scheduleDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  int.parse(_selectedTimeSlot!.split(':')[0]),
                );

                context.push('/booking/confirmation', extra: {
                  'childId': _selectedChild?.id ?? '',
                  'childName': _selectedChild?.name ?? '',
                  'therapistId': widget.therapistId,
                  'therapistName': widget.therapistName,
                  'schedule': scheduleDate.toIso8601String(),
                  'time': _selectedTimeSlot,
                  'date': DateFormat('dd MMM yyyy').format(_selectedDate),
                  'therapyType': 'Terapi Bicara',
                  'amount': 165000,
                });
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canBook ? AppConstants.primaryBlue : const Color(0xFFD1D5DB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          'Lanjut ke Pembayaran',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
