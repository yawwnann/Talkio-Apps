import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/loading_widget.dart';

class TherapistDetailPage extends ConsumerStatefulWidget {
  final String therapistId;
  final String therapistName;

  const TherapistDetailPage({
    super.key,
    required this.therapistId,
    required this.therapistName,
  });

  @override
  ConsumerState<TherapistDetailPage> createState() => _TherapistDetailPageState();
}

class _TherapistDetailPageState extends ConsumerState<TherapistDetailPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _therapistData;
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadTherapistDetail();
  }

  Future<void> _loadTherapistDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getTherapistDetail(widget.therapistId);
      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        if (resData['status'] == 'success') {
          setState(() {
            _therapistData = resData['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = resData['message'] ?? 'Gagal memuat detail terapis';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Gagal memuat data dari server';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isParent = authState.user?.role == 'PARENT';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Therapist',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : _error != null
              ? _buildErrorWidget()
               : _buildContentWidget(isParent),
      bottomNavigationBar: _isLoading || _error != null ? null : _buildBottomBar(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Detail',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Terjadi kesalahan tidak dikenal.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTherapistDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContentWidget(bool isParent) {
    if (_therapistData == null) return const SizedBox();
    
    final name = _therapistData!['name'] ?? widget.therapistName;
    final specialization = _therapistData!['specialization'] ?? 'Terapi Bicara & Wicara';
    final rating = _therapistData!['rating'] ?? 4.5;
    final bio = _therapistData!['bio'] ?? '';
    final reviews = _therapistData!['reviews'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Therapist Profile Card Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    size: 40,
                    color: AppConstants.primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialization,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Stats Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Color(0xFFD97706)),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFD97706),
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
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Bio / About
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tentang Terapis',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bio,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.6,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Testimonials List Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Testimoni Orang Tua',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (isParent)
                      TextButton.icon(
                        onPressed: _showWriteReviewDialog,
                        icon: const Icon(Icons.edit_note, size: 18),
                        label: Text(
                          'Tulis Testimoni',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppConstants.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                reviews.isEmpty
                    ? _buildEmptyReviews()
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return _buildReviewItem(review);
                        },
                      ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showWriteReviewDialog() {
    final ratingController = TextEditingController();
    final commentController = TextEditingController();
    int selectedRating = 5;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Tulis Testimoni',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rating', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < selectedRating ? Icons.star : Icons.star_border,
                              color: const Color(0xFFD97706),
                              size: 36,
                            ),
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Bagikan pengalaman Anda...',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Batal', style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: Text('Kirim', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, size: 48, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          Text(
            'Belum ada testimoni',
            style: GoogleFonts.poppins(
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jadilah yang pertama memberikan testimoni',
            style: GoogleFonts.poppins(
              color: const Color(0xFFCBD5E1),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(dynamic review) {
    final reviewerName = (review['parentName'] as String?) ?? 'Orang Tua';
    final rating = (review['rating'] as num?)?.toDouble() ?? 5.0;
    final comment = review['comment'] as String? ?? '';
    final date = review['createdAt'] as String? ?? '';
    final formattedDate = date.isNotEmpty ? date.split('T')[0] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
              child: Text(
                reviewerName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  color: AppConstants.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reviewerName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.round() ? Icons.star : Icons.star_border,
                    size: 14,
                    color: const Color(0xFFD97706),
                  );
                }),
              ),
            ),
          ],
        ),
        if (comment.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            comment,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.5,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              context.push('/booking/schedule', extra: {
                'therapistId': widget.therapistId,
                'therapistName': widget.therapistName,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pilih Jadwal',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
