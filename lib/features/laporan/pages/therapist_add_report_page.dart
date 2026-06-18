import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/anak_model.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../anak/providers/anak_provider.dart';
import '../providers/laporan_provider_real.dart';

class TherapistAddReportPage extends ConsumerStatefulWidget {
  final String? initialPatientId;
  final String? initialLaporanId;

  const TherapistAddReportPage({
    super.key,
    this.initialPatientId,
    this.initialLaporanId,
  });

  @override
  ConsumerState<TherapistAddReportPage> createState() =>
      _TherapistAddReportPageState();
}

class _TherapistAddReportPageState
    extends ConsumerState<TherapistAddReportPage> {
  double _speechClarity = 0.5; // Default value
  double _vocabulary = 0.5; // Default value
  double _socialInteraction = 0.5; // Default value
  AnakModel? _selectedPatient;
  DateTime _sessionDate = DateTime.now();
  final TextEditingController _progressNotesController = TextEditingController();
  final TextEditingController _barriersController = TextEditingController();
  List<String> _parentExercises = [];
  bool _isSubmitting = false;
  bool _isEditing = false;
  String? _editingLaporanId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(anakProvider.notifier).fetchAllAnak();
      if (widget.initialLaporanId != null) {
        // Ensure laporan list is loaded first
        await ref.read(laporanProvider.notifier).fetchLaporan();
        if (!mounted) return;
        _loadExistingLaporan();
      }
    });
  }

  void _loadExistingLaporan() {
    final laporanState = ref.read(laporanProvider);
    final anakState = ref.read(anakProvider);
    try {
      final laporan = laporanState.laporanList.firstWhere(
        (l) => l.id == widget.initialLaporanId,
      );
      final match = anakState.anakList.where((p) => p.id == laporan.patientId);
      setState(() {
        _isEditing = true;
        _editingLaporanId = laporan.id;
        _sessionDate = DateTime.tryParse(laporan.date) ?? DateTime.now();
        _progressNotesController.text = laporan.summary;
        if (match.isNotEmpty) {
          _selectedPatient = match.first;
        }
      });
    } catch (_) {
      // Not found, ignore
    }
  }

  void _onAnakLoaded(List<AnakModel> allAnak) {
    if (_selectedPatient != null) return;
    if (widget.initialPatientId != null) {
      final match = allAnak.where((p) => p.id == widget.initialPatientId);
      if (match.isNotEmpty) {
        setState(() => _selectedPatient = match.first);
        return;
      }
    }
    if (allAnak.isNotEmpty) {
      setState(() => _selectedPatient = allAnak.first);
    }
  }

  @override
  void dispose() {
    _progressNotesController.dispose();
    _barriersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakProvider);
    final allAnak = anakState.anakList;

    _onAnakLoaded(allAnak);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientSelection(allAnak),
                  const SizedBox(height: 16),
                  _buildSessionInfo(),
                  const SizedBox(height: 16),
                  _buildProgressNotes(),
                  const SizedBox(height: 16),
                  _buildBarriersChallenges(),
                  const SizedBox(height: 16),
                  _buildParentExercises(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppConstants.primaryBlue),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing ? 'Edit Laporan' : 'Tambah Laporan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              fontSize: 16,
            ),
          ),
          Text(
            'Laporan perkembangan pasien',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSelection(List<AnakModel> allAnak) {
    final name = _selectedPatient?.name ?? 'Pilih Pasien';
    final isMale = _selectedPatient?.gender == 'L';
    final readOnly = widget.initialPatientId != null;

    return GestureDetector(
      onTap: readOnly ? null : () {
        if (allAnak.isNotEmpty) {
          _showPatientSelectionBottomSheet(allAnak);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            ProfileAvatar(
              imageUrl: null,
              name: name,
              radius: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    readOnly
                        ? 'Pasien'
                        : (_selectedPatient != null
                            ? 'Tap untuk ganti pasien'
                            : 'Pilih pasien terlebih dahulu'),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (!readOnly)
              Icon(
                Icons.keyboard_arrow_down,
                color: const Color(0xFF9CA3AF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showPatientSelectionBottomSheet(List<AnakModel> patients) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Pilih Pasien',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final p = patients[index];
                    final isSelected = _selectedPatient?.id == p.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppConstants.primaryBlue.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected 
                              ? AppConstants.primaryBlue 
                              : const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: ProfileAvatar(name: p.name, radius: 18),
                        title: Text(
                          p.name,
                          style: GoogleFonts.poppins(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppConstants.primaryBlue,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          setState(() => _selectedPatient = p);
                          Navigator.pop(context);
                        },
                      ),
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
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _sessionDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _sessionDate = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: AppConstants.primaryBlue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Sesi',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          _formatDate(_sessionDate),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.format_list_numbered_outlined,
                  size: 18,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesi Ke',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        'Otomatis',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildSkillEvaluation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.bar_chart_rounded,
                  color: AppConstants.primaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Evaluasi Keterampilan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCustomSlider(
            "Kejelasan Bicara",
            _speechClarity,
            const Color(0xFF2563EB),
            (val) => setState(() => _speechClarity = val),
          ),
          const SizedBox(height: 16),
          _buildCustomSlider(
            "Kosakata",
            _vocabulary,
            const Color(0xFF10B981),
            (val) => setState(() => _vocabulary = val),
          ),
          const SizedBox(height: 16),
          _buildCustomSlider(
            "Interaksi Sosial",
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Catatan Perkembangan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              controller: _progressNotesController,
              maxLines: 4,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                hintText: 'Jelaskan pencapaian dan kemajuan pasien...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarriersChallenges() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Hambatan & Tantangan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              controller: _barriersController,
              maxLines: 3,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                hintText: 'Identifikasi kesulitan yang dihadapi...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentExercises() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: Color(0xFF059669),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Latihan di Rumah',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_parentExercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: const Color(0xFF6B7280)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tambahkan latihan untuk orang tua',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._parentExercises.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final exercise = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildExerciseItem(
                  index.toString().padLeft(2, '0'),
                  exercise,
                  onRemove: () {
                    setState(() {
                      _parentExercises.removeAt(entry.key);
                    });
                  },
                ),
              );
            }).toList(),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _addNewExercise,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: const Color(0xFF6B7280), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Tambah Latihan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(String number, String text, {VoidCallback? onRemove}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF059669),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Future<void> _addNewExercise() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Tambah Latihan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan deskripsi latihan...',
                hintStyle: GoogleFonts.poppins(color: const Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.poppins(color: const Color(0xFF6B7280))),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Tambah', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _parentExercises.add(result.trim());
      });
    }
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        print('🔘 [DEBUG] DRAFT BUTTON PRESSED!');
                        print('🔘 [DEBUG] _selectedPatient = ${_selectedPatient?.name}');
                        _submitReport(isDraft: true);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B5563)),
                        ),
                      )
                    : Text(
                        'Draft',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        print('🔘 [DEBUG] KIRIM BUTTON PRESSED!');
                        print('🔘 [DEBUG] _selectedPatient = ${_selectedPatient?.name}');
                        _submitReport(isDraft: false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Kirim ke Orang Tua',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
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
    );
  }

  Future<void> _submitReport({bool isDraft = false}) async {
    print('========================================');
    print('🔘 [_submitReport] Called with isDraft=$isDraft');
    print('🔘 [_submitReport] _isSubmitting=$_isSubmitting');
    print('🔘 [_submitReport] _selectedPatient=$_selectedPatient');
    print('========================================');
    
    // Validate required fields
    if (_selectedPatient == null) {
      print('❌ [_submitReport] No patient selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih pasien terlebih dahulu')),
      );
      return;
    }

    if (_progressNotesController.text.trim().isEmpty && !isDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress notes tidak boleh kosong')),
      );
      return;
    }

    // DEBUG: Print what we're about to send
    final notesPreview = _progressNotesController.text.trim();
    final safePreview = notesPreview.length > 50 
        ? '${notesPreview.substring(0, 50)}...' 
        : notesPreview;
    print('========================================');
    print('📤 SUBMITTING REPORT (REAL API)');
    print('  Patient ID: ${_selectedPatient!.id}');
    print('  Title: ${isDraft ? 'Draft Laporan' : 'Laporan Perkembangan'}');
    print('  Notes: $safePreview');
    print('  Date: ${_sessionDate.toIso8601String()}');
    print('========================================');

    setState(() {
      _isSubmitting = true;
    });

    try {
      // DIRECT API CALL - NO MOCK!
      final notifier = ref.read(laporanProvider.notifier);

      bool success;
      if (_isEditing && _editingLaporanId != null) {
        final reportStatus = isDraft ? "DRAFT" : "SENT";
        success = await notifier.updateLaporan(
          laporanId: _editingLaporanId!,
          childId: _selectedPatient!.id,
          title: isDraft ? 'Draft Laporan' : 'Laporan Perkembangan',
          progressNotes: _progressNotesController.text.trim(),
          sessionDate: _sessionDate.toIso8601String(),
          speechClarity: _speechClarity,
          vocabulary: _vocabulary,
          socialInteraction: _socialInteraction,
          barriers: _barriersController.text.trim(),
          parentExercises: _parentExercises,
          status: reportStatus,
        );
      } else {
        final reportStatus = isDraft ? "DRAFT" : "SENT";
        success = await notifier.createLaporan(
          childId: _selectedPatient!.id,
          title: isDraft ? 'Draft Laporan' : 'Laporan Perkembangan',
          progressNotes: _progressNotesController.text.trim(),
          sessionDate: _sessionDate.toIso8601String(),
          speechClarity: _speechClarity,
          vocabulary: _vocabulary,
          socialInteraction: _socialInteraction,
          barriers: _barriersController.text.trim(),
          parentExercises: _parentExercises,
          status: reportStatus, // Send DRAFT or SENT
        );
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Laporan berhasil diperbarui!'
                  : (isDraft ? 'Draft berhasil disimpan!' : 'Laporan berhasil dikirim!'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) {
          context.pop(); // back to previous screen (detail or list)
        }
      } else {
        final error = notifier.state.error ?? 'Gagal menyimpan laporan';
        throw Exception(error);
      }
    } catch (e) {
      print('========================================');
      print('❌ ERROR SUBMITTING REPORT');
      print('  Error: $e');
      print('========================================');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
