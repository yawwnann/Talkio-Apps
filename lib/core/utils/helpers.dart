import 'package:intl/intl.dart';

/// Helper Functions
/// Berisi fungsi-fungsi bantuan yang sering digunakan
class Helpers {
  // Format currency to Indonesian Rupiah
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  // Format date to Indonesian format
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }
  
  // Format date with time
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
    return formatter.format(dateTime);
  }
  
  // Format time only
  static String formatTime(DateTime time) {
    final formatter = DateFormat('HH:mm', 'id_ID');
    return formatter.format(time);
  }
  
  // Calculate age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
  
  // Generate random ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  // Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
  
  // Check if string is valid URL
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }
}