import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/services/midtrans_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/custom_app_bar.dart';

/// Payment Page
/// Halaman pembayaran menggunakan Midtrans Snap
class PaymentPage extends ConsumerStatefulWidget {
  final String orderId;
  final double amount;
  final Map<String, dynamic> customerDetails;

  const PaymentPage({
    super.key,
    required this.orderId,
    required this.amount,
    required this.customerDetails,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  late WebViewController _webViewController;
  final MidtransService _midtransService = MidtransService();

  bool _isLoading = true;
  String? _error;
  String? _snapToken;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Create transaction and get snap token
      final snapToken = await _midtransService.createTransaction(
        orderId: widget.orderId,
        grossAmount: widget.amount,
        customerDetails: widget.customerDetails,
      );

      setState(() {
        _snapToken = snapToken;
        _isLoading = false;
      });

      // Initialize WebView
      _initializeWebView();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _initializeWebView() {
    if (_snapToken == null) return;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Handle page start
          },
          onPageFinished: (String url) {
            // Handle page finish
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle navigation
            if (request.url.startsWith('speechtherapy://')) {
              _handlePaymentCallback(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://app.sandbox.midtrans.com/snap/v2/vtweb/$_snapToken'),
      );
  }

  void _handlePaymentCallback(String url) {
    if (url.contains('finish')) {
      _handlePaymentSuccess();
    } else if (url.contains('error')) {
      _handlePaymentError();
    } else if (url.contains('pending')) {
      _handlePaymentPending();
    }
  }

  void _handlePaymentSuccess() {
    Navigator.of(context).pop({'status': 'success'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran berhasil!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePaymentError() {
    Navigator.of(context).pop({'status': 'error'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran gagal!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handlePaymentPending() {
    Navigator.of(context).pop({'status': 'pending'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran pending, silakan selesaikan pembayaran'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Pembayaran',
        onBackPress: () => Navigator.of(context).pop({'status': 'cancelled'}),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Memproses pembayaran...');
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal Memproses Pembayaran',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(text: 'Coba Lagi', onPressed: _initializePayment),
            ],
          ),
        ),
      );
    }

    if (_snapToken != null) {
      return WebViewWidget(controller: _webViewController);
    }

    return const SizedBox.shrink();
  }
}

/// Payment Summary Page
/// Halaman ringkasan pembayaran sebelum proses
class PaymentSummaryPage extends StatelessWidget {
  final String serviceName;
  final double amount;
  final Map<String, dynamic> customerDetails;

  const PaymentSummaryPage({
    super.key,
    required this.serviceName,
    required this.amount,
    required this.customerDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const SimpleAppBar(title: 'Ringkasan Pembayaran'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Service Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Layanan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.medical_services, color: theme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                serviceName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Sesi terapi speech delay',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Helpers.formatCurrency(amount),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Pelanggan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      'Nama',
                      '${customerDetails['first_name']} ${customerDetails['last_name']}',
                    ),
                    _buildInfoRow(context, 'Email', customerDetails['email']),
                    _buildInfoRow(context, 'Telepon', customerDetails['phone']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Methods Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Anda dapat memilih berbagai metode pembayaran:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentMethodItem(
                      context,
                      Icons.credit_card,
                      'Kartu Kredit/Debit',
                    ),
                    _buildPaymentMethodItem(
                      context,
                      Icons.account_balance,
                      'Transfer Bank',
                    ),
                    _buildPaymentMethodItem(
                      context,
                      Icons.wallet,
                      'E-Wallet (GoPay, ShopeePay)',
                    ),
                    _buildPaymentMethodItem(context, Icons.qr_code, 'QRIS'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Total Pembayaran',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Helpers.formatCurrency(amount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pay Button
            CustomButton(
              text: 'Bayar Sekarang',
              onPressed: () => _processPayment(context),
              icon: Icons.payment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(
    BuildContext context,
    IconData icon,
    String name,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(name, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context) {
    final orderId = MidtransService.generateOrderId();

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              orderId: orderId,
              amount: amount,
              customerDetails: customerDetails,
            ),
          ),
        )
        .then((result) {
          if (!context.mounted) return;
          if (result != null) {
            // Handle payment result
            Navigator.of(context).pop(result);
          }
        });
  }
}
