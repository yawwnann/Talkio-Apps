import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/anak_model.dart';
import '../../anak/providers/anak_provider.dart';

class TherapistAddReportPage extends ConsumerStatefulWidget {
  const TherapistAddReportPage({super.key});

  @override
  ConsumerState<TherapistAddReportPage> createState() =>
      _TherapistAddReportPageState();
}

class _TherapistAddReportPageState
    extends ConsumerState<TherapistAddReportPage> {
  double _speechClarity = 0.75;
  double _vocabulary = 0.60;
  double _socialInteraction = 0.85;
  AnakModel? _selectedPatient;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(anakProvider.notifier).fetchAllAnak();
    });
  }

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakProvider);
    final allAnak = anakState.anakList;

    // Auto-select first patient if available and empty
    if (_selectedPatient == null && allAnak.isNotEmpty) {
      _selectedPatient = allAnak.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Very light grey background
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 120, // space for bottom action bar
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPatientSelection(allAnak),
                const SizedBox(height: 16),
                _buildSessionInfo(),
                const SizedBox(height: 24),
                _buildSkillEvaluation(),
                const SizedBox(height: 24),
                _buildProgressNotes(),
                const SizedBox(height: 24),
                _buildBarriersChallenges(),
                const SizedBox(height: 24),
                _buildParentExercises(),
              ],
            ),
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FC),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'New Development Report',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2937),
          fontSize: 16,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPatientSelection(List<AnakModel> allAnak) {
    final name = _selectedPatient?.name ?? 'Memuat Pasien...';
    final idToken = _selectedPatient != null
        ? 'LK-2024-${_selectedPatient!.id.hashCode.toString().substring(0, 3)}'
        : '...';
    final isMale = _selectedPatient?.gender == 'L';

    return GestureDetector(
      onTap: () {
        if (allAnak.isNotEmpty) {
          _showPatientSelectionBottomSheet(allAnak);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PATIENT SELECTION',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage(
                        isMale
                            ? 'assets/images/boy_avatar.png'
                            : 'assets/images/girl_avatar.png',
                      ),
                      backgroundColor: const Color(0xFFF3F4F6),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Patient ID: ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            idToken,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPatientSelectionBottomSheet(List<AnakModel> patients) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Pasien',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final p = patients[index];
                    final pIdToken =
                        'LK-2024-${p.id.hashCode.toString().substring(0, 3)}';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                          p.gender == 'L'
                              ? 'assets/images/boy_avatar.png'
                              : 'assets/images/girl_avatar.png',
                        ),
                      ),
                      title: Text(
                        p.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'ID: $pIdToken',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      onTap: () {
                        setState(() => _selectedPatient = p);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionInfo() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SESSION DATE',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppConstants.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Oct 24, 2023',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SESSION NO.',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '13 ',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          TextSpan(
                            text: 'of 16',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillEvaluation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bar_chart,
                      color: AppConstants.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Skill\nEvaluation',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'CURRENT\nSESSION',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppConstants.primaryBlue,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildCustomSlider(
            "Speech Clarity",
            _speechClarity,
            const Color(0xFF2563EB),
            (val) => setState(() => _speechClarity = val),
          ),
          const SizedBox(height: 20),
          _buildCustomSlider(
            "Vocabulary",
            _vocabulary,
            const Color(0xFF10B981),
            (val) => setState(() => _vocabulary = val),
          ),
          const SizedBox(height: 20),
          _buildCustomSlider(
            "Social Interaction",
            _socialInteraction,
            const Color(0xFFD97706),
            (val) => setState(() => _socialInteraction = val),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSlider(
    String label,
    double value,
    Color color,
    void Function(double) onChanged,
  ) {
    final percentText = '${(value * 100).toInt()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF374151),
              ),
            ),
            Text(
              percentText,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 24, // Taller bounds for easier gesture tracking
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final fillWidth = availableWidth * value;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  double localDx = details.localPosition.dx;
                  double percent = (localDx / availableWidth).clamp(0.0, 1.0);
                  onChanged(percent);
                },
                onTapDown: (details) {
                  double localDx = details.localPosition.dx;
                  double percent = (localDx / availableWidth).clamp(0.0, 1.0);
                  onChanged(percent);
                },
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      width: availableWidth,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: fillWidth,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Positioned(
                      left: fillWidth - (fillWidth > 14 ? 14 : 0),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressNotes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note,
                color: AppConstants.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Progress Notes',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              maxLines: 3,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                hintText: 'Describe milestones achieved...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarriersChallenges() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerLeft,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              36,
            ), // Consistent with Progress Notes
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE11D48),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Barriers & Challenges',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE11D48),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Identify difficulties faced...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF9CA3AF),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Custom curved red crescent on the left
        Positioned(
          left: -12, // Pull outside the left boundary of the white card
          child: Container(
            width: 24,
            height: 60,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFE11D48), width: 3),
                top: BorderSide(color: Color(0xFFE11D48), width: 3),
                bottom: BorderSide(color: Color(0xFFE11D48), width: 3),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParentExercises() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFFF7), // Light pale green
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background watermark
          Positioned(
            right: -20,
            top: -10,
            child: Icon(
              Icons.maps_home_work,
              size: 100,
              color: const Color(0xFFD1FAE5).withValues(alpha: 0.5),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.home, color: Color(0xFF059669), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Parent Exercises',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildExerciseItem(
                "01",
                "\"Use flashcards during breakfast to identify at least 3 new fruits.\"",
              ),
              const SizedBox(height: 10),
              _buildExerciseItem(
                "02",
                "\"Encourage eye contact for 5 seconds when asking for toys.\"",
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF34D399),
                    width: 1.5,
                  ),
                ),
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle, color: Color(0xFF059669)),
                  label: Text(
                    'Add New Exercise',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(String number, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF34D399),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF4B5563),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.delete_outline, color: Color(0xFF9CA3AF), size: 18),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Save Draft',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporn berhasil dikirim!')),
                    );
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Send to Parents',
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
            ),
          ],
        ),
      ),
    );
  }
}
