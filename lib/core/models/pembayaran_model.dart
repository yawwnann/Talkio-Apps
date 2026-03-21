/// Pembayaran Model
/// Model untuk data pembayaran terapi
class PembayaranModel {
  final String id;
  final String orderId;
  final String userId;
  final String jadwalId;
  final double amount;
  final String status; // pending, success, failed
  final String paymentMethod;
  final String? snapToken;
  final String? transactionId;
  final Map<String, dynamic>? paymentDetails;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;
  
  PembayaranModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.jadwalId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.snapToken,
    this.transactionId,
    this.paymentDetails,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
  });
  
  // Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FF9800'; // Orange
      case 'success':
        return '#4CAF50'; // Green
      case 'failed':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }
  
  // Get status text
  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'success':
        return 'Berhasil';
      case 'failed':
        return 'Gagal';
      default:
        return 'Tidak Diketahui';
    }
  }
  
  // Format amount to currency
  String get formattedAmount {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
  
  // Get payment method display name
  String get paymentMethodName {
    switch (paymentMethod.toLowerCase()) {
      case 'credit_card':
        return 'Kartu Kredit';
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'gopay':
        return 'GoPay';
      case 'shopeepay':
        return 'ShopeePay';
      case 'qris':
        return 'QRIS';
      case 'bca_va':
        return 'BCA Virtual Account';
      case 'bni_va':
        return 'BNI Virtual Account';
      case 'bri_va':
        return 'BRI Virtual Account';
      default:
        return paymentMethod;
    }
  }
  
  // Check if payment is expired (24 hours)
  bool get isExpired {
    if (status != 'pending') return false;
    
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours >= 24;
  }
  
  // Convert from JSON
  factory PembayaranModel.fromJson(Map<String, dynamic> json) {
    return PembayaranModel(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      userId: json['user_id'] ?? '',
      jadwalId: json['jadwal_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      snapToken: json['snap_token'],
      transactionId: json['transaction_id'],
      paymentDetails: json['payment_details'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'jadwal_id': jadwalId,
      'amount': amount,
      'status': status,
      'payment_method': paymentMethod,
      'snap_token': snapToken,
      'transaction_id': transactionId,
      'payment_details': paymentDetails,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
    };
  }
  
  // Copy with new values
  PembayaranModel copyWith({
    String? id,
    String? orderId,
    String? userId,
    String? jadwalId,
    double? amount,
    String? status,
    String? paymentMethod,
    String? snapToken,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
  }) {
    return PembayaranModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      jadwalId: jadwalId ?? this.jadwalId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      snapToken: snapToken ?? this.snapToken,
      transactionId: transactionId ?? this.transactionId,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }
  
  @override
  String toString() {
    return 'PembayaranModel(id: $id, orderId: $orderId, amount: $formattedAmount, status: $status)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is PembayaranModel &&
        other.id == id &&
        other.orderId == orderId &&
        other.amount == amount &&
        other.status == status;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        orderId.hashCode ^
        amount.hashCode ^
        status.hashCode;
  }
}