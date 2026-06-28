import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/admin_bottom_nav.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/admin_payment_provider.dart';

class AdminPaymentPage extends ConsumerStatefulWidget {
  const AdminPaymentPage({super.key});

  @override
  ConsumerState<AdminPaymentPage> createState() => _AdminPaymentPageState();
}

class _AdminPaymentPageState extends ConsumerState<AdminPaymentPage> {
  int _selectedTab = 0; // 0 = Semua, 1 = Sukses, 2 = Pending, 3 = Gagal
  final List<String> _tabs = ['Semua', 'Sukses', 'Pending', 'Gagal'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedMonth = 0; // 0 = Semua Bulan, 1 = Jan, 2 = Feb, dll.
  final List<String> _months = [
    'Semua Bulan',
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    final transactions = ref.watch(adminPaymentProvider).transactions;
    return transactions.where((trx) {
      final id = trx['id']?.toString().toLowerCase() ?? '';
      final transactionId = trx['transactionId']?.toString().toLowerCase() ?? '';
      final patientName = trx['patientName']?.toString().toLowerCase() ?? '';
      final matchesSearch = id.contains(_searchQuery.toLowerCase()) ||
          transactionId.contains(_searchQuery.toLowerCase()) ||
          patientName.contains(_searchQuery.toLowerCase());
      final matchesTab = _selectedTab == 0 ||
          (_selectedTab == 1 && trx['status'] == 'SUCCESS') ||
          (_selectedTab == 2 && trx['status'] == 'PENDING') ||
          (_selectedTab == 3 && trx['status'] == 'FAILED');
          
      bool matchesMonth = true;
      if (_selectedMonth > 0) {
        try {
          final dateStr = trx['date']?.toString() ?? '';
          final date = DateTime.parse(dateStr);
          matchesMonth = date.month == _selectedMonth;
        } catch (_) {
          // If parsing fails, we might just show it or hide it. Let's hide it if a specific month is selected.
          matchesMonth = false;
        }
      }
      
      return matchesSearch && matchesTab && matchesMonth;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminPaymentProvider.notifier).fetchPayments();
    });
  }

  Future<void> _fetchPayments() async {
    await ref.read(adminPaymentProvider.notifier).fetchPayments();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminPaymentProvider);
    final filteredTransactions = _filteredTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(state),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          _buildSummaryCards(state),
          Expanded(
            child: state.isLoading
                ? const Center(child: LoadingWidget())
                : filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionList(filteredTransactions),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }

  PreferredSizeWidget _buildAppBar(AdminPaymentState state) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manajemen Pembayaran',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              fontSize: 16,
            ),
          ),
          Text(
            '${state.total} transaksi',
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
          onPressed: _fetchPayments,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Cari transaksi...',
                  hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Color(0xFF9CA3AF)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedMonth,
                icon: const Icon(Icons.calendar_month, size: 18, color: Color(0xFF6B7280)),
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF111827)),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedMonth = newValue);
                  }
                },
                items: List.generate(_months.length, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(_months[index]),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildSummaryCards(AdminPaymentState state) {
    final successCount = state.summary['success'] ?? 0;
    final pendingCount = state.summary['pending'] ?? 0;
    final failedCount = state.summary['failed'] ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryChip('Sukses', successCount, const Color(0xFF10B981)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryChip('Pending', pendingCount, const Color(0xFFF59E0B)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryChip('Gagal', failedCount, const Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final trx = transactions[index];
        return _buildTransactionCard(trx);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> trx) {
    final status = trx['status'];
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

    return GestureDetector(
      onTap: () => _showTransactionDetail(trx),
      child: Container(
        padding: const EdgeInsets.all(12),
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
                  trx['id'],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 18,
                    color: AppConstants.primaryBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trx['patientName'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        trx['therapyType'],
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
                Expanded(
                  child: Text(
                    trx['date'],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                Text(
                  'Rp ${trx['amount'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada transaksi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah filter atau kata kunci pencarian',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(Map<String, dynamic> trx) {
    final status = trx['status'];
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Detail Transaksi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID Transaksi', trx['id']),
              _buildDetailRow('Status', statusLabel, color: statusColor),
              const Divider(),
              _buildDetailRow('Pasien', trx['patientName']),
              _buildDetailRow('Terapis', trx['therapistName']),
              _buildDetailRow('Jenis Terapi', trx['therapyType']),
              const Divider(),
              _buildDetailRow('Metode Pembayaran', trx['paymentMethod'].toUpperCase()),
              _buildDetailRow('Tanggal', trx['date']),
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
                    'Rp ${trx['amount'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
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
            width: 100,
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
