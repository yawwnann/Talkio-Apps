import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/parent_payment_provider.dart';
import '../../../shared/widgets/parent_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../../shared/widgets/loading_widget.dart';

class ParentPembayaranPage extends ConsumerStatefulWidget {
  const ParentPembayaranPage({super.key});

  @override
  ConsumerState<ParentPembayaranPage> createState() => _ParentPembayaranPageState();
}

class _ParentPembayaranPageState extends ConsumerState<ParentPembayaranPage> {
  int _selectedTab = 0; // 0 = Semua, 1 = Sukses, 2 = Pending, 3 = Gagal
  final List<String> _tabs = ['Semua', 'Sukses', 'Pending', 'Gagal'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(parentPaymentProvider.notifier).fetchPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(parentPaymentProvider);
    final payments = paymentState.paymentList;

    // Filter payments based on selected tab
    final filteredPayments = payments.where((p) {
      final status = p['paymentStatus'];
      switch (_selectedTab) {
        case 1:
          return status == 'SUCCESS';
        case 2:
          return status == 'PENDING';
        case 3:
          return status == 'FAILED';
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: paymentState.isLoading
                ? const Center(child: LoadingWidget())
                : paymentState.error != null
                    ? _buildErrorState(paymentState.error!)
                    : filteredPayments.isEmpty
                        ? _buildEmptyState()
                        : _buildPaymentList(filteredPayments),
          ),
        ],
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 2),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Pembayaran',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              fontSize: 16,
            ),
          ),
          Text(
            'Kelola pembayaran terapi',
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
          onPressed: () => ref.read(parentPaymentProvider.notifier).fetchPayments(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppConstants.primaryBlue : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _tabs[index],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPaymentList(List<Map<String, dynamic>> payments) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: payments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final status = payment['paymentStatus'];
    Color statusColor;
    String statusLabel;

    switch (status) {
      case 'SUCCESS':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Sukses';
        break;
      case 'PENDING':
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Pending';
        break;
      case 'FAILED':
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'Gagal';
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusLabel = status;
    }

    final amount = payment['amount'] ?? 0;
    final scheduleDate = DateTime.parse(payment['schedule']);
    final dateStr = DateFormat('dd MMM yyyy').format(scheduleDate);

    return GestureDetector(
      onTap: () => _showPaymentDetail(payment),
      child: Container(
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
                  name: payment['childName'],
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment['childName'] ?? '-',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        payment['therapyType'] ?? '-',
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
                Icon(Icons.attach_money, size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  'Rp ${NumberFormat('#,###').format(amount)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                if (status == 'PENDING')
                  GestureDetector(
                    onTap: () => _payNow(payment),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Bayar',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: const Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat pembayaran',
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
            onPressed: () => ref.read(parentPaymentProvider.notifier).fetchPayments(),
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
          Icon(Icons.payment_outlined, size: 64, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text(
            'Belum ada pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Riwayat pembayaran akan muncul di sini',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _payNow(Map<String, dynamic> payment) async {
    final paymentUrl = payment['paymentUrl'];
    if (paymentUrl == null || paymentUrl.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL pembayaran tidak tersedia')),
      );
      return;
    }
    final result = await context.push<bool>('/payment/webview', extra: {
      'paymentUrl': paymentUrl,
      'sessionId': payment['sessionId'] ?? payment['id'],
    });
    if (result == true) {
      ref.read(parentPaymentProvider.notifier).fetchPayments();
    }
  }

  void _showPaymentDetail(Map<String, dynamic> payment) {
    final status = payment['paymentStatus'];
    Color statusColor;
    String statusLabel;

    switch (status) {
      case 'SUCCESS':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Sukses';
        break;
      case 'PENDING':
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Pending';
        break;
      case 'FAILED':
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'Gagal';
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusLabel = status;
    }

    final amount = payment['amount'] ?? 0;
    final scheduleDate = DateTime.parse(payment['schedule']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Detail Pembayaran', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Status', statusLabel, color: statusColor),
              const Divider(),
              _buildDetailRow('Pasien', payment['childName']),
              _buildDetailRow('Jenis Terapi', payment['therapyType']),
              const Divider(),
              _buildDetailRow('Tanggal', DateFormat('dd MMM yyyy').format(scheduleDate)),
              _buildDetailRow('Waktu', DateFormat('HH:mm').format(scheduleDate)),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###').format(amount)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (status == 'PENDING')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _payNow(payment);
              },
              child: Text('Bayar Sekarang', style: GoogleFonts.poppins(color: AppConstants.primaryBlue, fontWeight: FontWeight.w600)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.poppins(color: AppConstants.primaryBlue)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280)),
            ),
          ),
          Text(
            ':',
            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color ?? const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
