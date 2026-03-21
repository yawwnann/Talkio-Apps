import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Midtrans Service
/// Service untuk handle pembayaran menggunakan Midtrans
class MidtransService {
  late final Dio _dio;
  
  MidtransService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.midtransBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Basic ${base64Encode(utf8.encode('${AppConstants.midtransServerKey}:'))}',
      },
    ));
  }
  
  /// Create transaction and get snap token
  Future<String> createTransaction({
    required String orderId,
    required double grossAmount,
    required Map<String, dynamic> customerDetails,
    List<Map<String, dynamic>>? itemDetails,
  }) async {
    try {
      final data = {
        'transaction_details': {
          'order_id': orderId,
          'gross_amount': grossAmount.toInt(),
        },
        'customer_details': customerDetails,
        'item_details': itemDetails ?? [
          {
            'id': 'therapy_session',
            'price': grossAmount.toInt(),
            'quantity': 1,
            'name': 'Sesi Terapi Speech Delay',
          }
        ],
        'credit_card': {
          'secure': true,
        },
        'callbacks': {
          'finish': 'speechtherapy://payment/finish',
          'error': 'speechtherapy://payment/error',
          'pending': 'speechtherapy://payment/pending',
        },
      };
      
      final response = await _dio.post('/transactions', data: data);
      
      if (response.statusCode == 201) {
        return response.data['token'];
      } else {
        throw Exception('Gagal membuat transaksi: ${response.data['error_messages']}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Error Midtrans: ${e.response?.data['error_messages'] ?? e.message}');
      }
      throw Exception('Gagal membuat transaksi: ${e.toString()}');
    }
  }
  
  /// Check transaction status
  Future<Map<String, dynamic>> checkTransactionStatus(String orderId) async {
    try {
      final response = await _dio.get('/$orderId/status');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Gagal mengecek status transaksi');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Error Midtrans: ${e.response?.data['error_messages'] ?? e.message}');
      }
      throw Exception('Gagal mengecek status transaksi: ${e.toString()}');
    }
  }
  
  /// Cancel transaction
  Future<bool> cancelTransaction(String orderId) async {
    try {
      final response = await _dio.post('/$orderId/cancel');
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Generate order ID
  static String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORDER-$timestamp';
  }
  
  /// Format customer details
  static Map<String, dynamic> formatCustomerDetails({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
    };
  }
  
  /// Get payment method name
  static String getPaymentMethodName(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'credit_card':
        return 'Kartu Kredit';
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'echannel':
        return 'Mandiri Bill';
      case 'permata':
        return 'Permata VA';
      case 'bca_va':
        return 'BCA Virtual Account';
      case 'bni_va':
        return 'BNI Virtual Account';
      case 'bri_va':
        return 'BRI Virtual Account';
      case 'gopay':
        return 'GoPay';
      case 'shopeepay':
        return 'ShopeePay';
      case 'qris':
        return 'QRIS';
      default:
        return paymentType;
    }
  }
}