import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pembayaran_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/utils/helpers.dart';
import 'payment_page.dart';
import '../../../shared/widgets/custom_app_bar.dart';

/// Pembayaran List Page
/// Halaman daftar riwayat pembayaran
class PembayaranListPage extends ConsumerStatefulWidget {
  const PembayaranListPage({super.key});

  @override
  ConsumerState<PembayaranListPage> createState() => _PembayaranListPageState();
}

class _PembayaranListPageState extends ConsumerState<PembayaranListPage> {
  bool _isLoading = true;
  List<PembayaranModel> _pembayaranList = [];

  @override
  void initState() {
    super.initState();
    _loadPembayaranData();
  }

  Future<void> _loadPembayaranData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call with mock data
    await Future.delayed(const Duration(seconds: 1));

    final mockData = [
      PembayaranModel(
        id: '1',
        orderId: 'ORDER-1234567890',
        userId: 'user1',
        jadwalId: 'jadwal1',
        amount: 150000,
        status: 'success',
        paymentMethod: 'gopay',
        transactionId: 'TXN-123456',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        paidAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PembayaranModel(
        id: '2',
        orderId: 'ORDER-1234567891',
        userId: 'user1',
        jadwalId: 'jadwal2',
        amount: 150000,
        status: 'pending',
        paymentMethod: 'bca_va',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PembayaranModel(
        id: '3',
        orderId: 'ORDER-1234567892',
        userId: 'user1',
        jadwalId: 'jadwal3',
        amount: 150000,
        status: 'failed',
        paymentMethod: 'credit_card',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    setState(() {
      _pembayaranList = mockData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Riwayat Pembayaran',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPembayaranData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPembayaranData,
        child: _buildBody(theme),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewPaymentDialog,
        icon: const Icon(Icons.payment),
        label: const Text('Bayar Terapi'),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Memuat riwayat pembayaran...');
    }

    // if (_pembayaranList.isEmpty) {
    //   return const EmptyStateWidget(
    //     icon: Icons.payment,
    //     title: 'Belum Ada Pembayaran',
    //     subtitle: 'Riwayat pembayaran Anda akan muncul di sini',
    //   );
    // }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pembayaranList.length,
      itemBuilder: (context, index) {
        final pembayaran = _pembayaranList[index];
        return _buildPembayaranCard(theme, pembayaran);
      },
    );
  }

  Widget _buildPembayaranCard(ThemeData theme, PembayaranModel pembayaran) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    pembayaran.orderId,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(
                            pembayaran.statusColor.substring(1),
                            radix: 16,
                          ) +
                          0xFF000000,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pembayaran.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(
                        int.parse(
                              pembayaran.statusColor.substring(1),
                              radix: 16,
                            ) +
                            0xFF000000,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Amount
            Text(
              pembayaran.formattedAmount,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),

            const SizedBox(height: 8),

            // Payment Method
            Row(
              children: [
                Icon(
                  _getPaymentMethodIcon(pembayaran.paymentMethod),
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  pembayaran.paymentMethodName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Date
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  Helpers.formatDateTime(pembayaran.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            // Actions for pending payments
            if (pembayaran.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _continuePayment(pembayaran),
                      child: const Text('Lanjutkan Pembayaran'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _cancelPayment(pembayaran),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Batalkan'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'credit_card':
        return Icons.credit_card;
      case 'bank_transfer':
      case 'bca_va':
      case 'bni_va':
      case 'bri_va':
        return Icons.account_balance;
      case 'gopay':
      case 'shopeepay':
        return Icons.wallet;
      case 'qris':
        return Icons.qr_code;
      default:
        return Icons.payment;
    }
  }

  void _continuePayment(PembayaranModel pembayaran) {
    // Navigate to payment page with existing order
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              orderId: pembayaran.orderId,
              amount: pembayaran.amount,
              customerDetails: {
                'first_name': 'John',
                'last_name': 'Doe',
                'email': 'john.doe@example.com',
                'phone': '081234567890',
              },
            ),
          ),
        )
        .then((result) {
          if (result != null) {
            _loadPembayaranData(); // Refresh data
          }
        });
  }

  void _cancelPayment(PembayaranModel pembayaran) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pembayaran'),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pembayaran ${pembayaran.orderId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement cancel payment API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pembayaran dibatalkan'),
                  backgroundColor: Colors.orange,
                ),
              );
              _loadPembayaranData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  void _showNewPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran Terapi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih jenis pembayaran:'),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.medical_services),
              title: Text('Sesi Terapi Individual'),
              subtitle: Text('Rp 150.000'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Sesi Terapi Grup'),
              subtitle: Text('Rp 100.000'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processNewPayment();
            },
            child: const Text('Pilih'),
          ),
        ],
      ),
    );
  }

  void _processNewPayment() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => PaymentSummaryPage(
              serviceName: 'Sesi Terapi Individual',
              amount: 150000,
              customerDetails: {
                'first_name': 'John',
                'last_name': 'Doe',
                'email': 'john.doe@example.com',
                'phone': '081234567890',
              },
            ),
          ),
        )
        .then((result) {
          if (result != null) {
            _loadPembayaranData(); // Refresh data
          }
        });
  }
}
