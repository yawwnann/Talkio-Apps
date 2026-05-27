import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_constants.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String sessionId;

  const PaymentWebViewPage({
    super.key,
    required this.paymentUrl,
    required this.sessionId,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // Check if this is a mock payment URL (for development/testing)
  bool get isMockPayment {
    return widget.paymentUrl.contains('/payment/mock') ||
        widget.paymentUrl.contains('localhost') ||
        widget.paymentUrl.contains('sandbox.midtrans.com') == false &&
            widget.paymentUrl.contains('midtrans') == false;
  }

  @override
  void initState() {
    super.initState();

    // If mock URL, skip WebView and show mock payment UI
    if (isMockPayment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMockPaymentDialog();
      });
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress: $progress%)');
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            debugPrint('Page finished loading: $url');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigation request: ${request.url}');

            // Intercept Midtrans finish URL
            if (request.url.contains('/payment/finish')) {
              if (mounted) {
                context.pop(true);
              }
              return NavigationDecision.prevent;
            }

            if (request.url.contains('/payment/unfinish') || request.url.contains('/payment/error')) {
              if (mounted) {
                context.pop(false);
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _showMockPaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.science, color: const Color(0xFFF59E0B), size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Mock Payment',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halaman pembayaran mock untuk testing.',
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            Text(
              'Session ID: ${widget.sessionId}',
              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih status pembayaran:',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop(false);
            },
            child: Text(
              'Batalkan',
              style: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop(false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: Text(
              'Gagal',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
            ),
            child: Text(
              'Berhasil',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If mock payment, show loading while dialog is shown
    if (isMockPayment) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF111827)),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Mock Pembayaran',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryBlue),
          ),
        ),
      );
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
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
                'Pembayaran',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                  fontSize: 16,
                ),
              ),
              Text(
                'Midtrans Secure Payment',
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
              onPressed: () => _controller.reload(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white.withValues(alpha: 0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryBlue),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Memuat halaman pembayaran...',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
