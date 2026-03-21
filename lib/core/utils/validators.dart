/// Validators
/// Berisi fungsi-fungsi validasi untuk form input
class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }
  
  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    return null;
  }
  
  // Name validation
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    
    if (value.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    
    return null;
  }
  
  // Phone validation
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    
    final phoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Format nomor telepon tidak valid';
    }
    
    return null;
  }
  
  // Age validation
  static String? age(String? value) {
    if (value == null || value.isEmpty) {
      return 'Umur tidak boleh kosong';
    }
    
    final age = int.tryParse(value);
    if (age == null || age < 1 || age > 18) {
      return 'Umur harus antara 1-18 tahun';
    }
    
    return null;
  }
  
  // Required field validation
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }
}