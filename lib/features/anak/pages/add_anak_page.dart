import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/anak_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/anak_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class AddAnakPage extends ConsumerStatefulWidget {
  const AddAnakPage({super.key});
  
  @override
  ConsumerState<AddAnakPage> createState() => _AddAnakPageState();
}

class _AddAnakPageState extends ConsumerState<AddAnakPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedBirthDate;
  String _selectedGender = 'MALE';
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(now.year - 3),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) setState(() => _selectedBirthDate = picked);
  }
  
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Pilih tanggal lahir'), backgroundColor: Colors.red),
      );
      return;
    }
    
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    final anak = AnakModel(
      id: '',
      parentId: user.id,
      name: _nameController.text.trim(),
      dateOfBirth: _selectedBirthDate!,
      gender: _selectedGender,
    );
    
    final success = await ref.read(anakProvider.notifier).addAnak(anak);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data anak berhasil ditambahkan'), backgroundColor: Colors.green),
      );
      context.pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const SimpleAppBar(title: 'Tambah Data Anak'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppConstants.primaryBlue.withValues(alpha: 0.1), AppConstants.darkBlue.withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConstants.primaryBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppConstants.primaryBlue, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.info_outline, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Lengkapi data anak untuk memulai terapi', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF2D3142))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama Lengkap Anak', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      validator: Validators.name,
                      decoration: _buildInputDecoration('Masukkan nama lengkap anak', Icons.child_care),
                    ),
                    const SizedBox(height: 20),
                    Text('Tanggal Lahir', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectBirthDate,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 12),
                            Text(
                              _selectedBirthDate != null
                                  ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                                  : 'Pilih tanggal lahir',
                              style: GoogleFonts.poppins(fontSize: 14, color: _selectedBirthDate != null ? Colors.black87 : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Jenis Kelamin', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildGenderOption('MALE', 'Laki-laki', Icons.male)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildGenderOption('FEMALE', 'Perempuan', Icons.female)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: anakState.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: anakState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text('Simpan Data Anak', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppConstants.primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Batal', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppConstants.primaryBlue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    final color = value == 'L' ? const Color(0xFF2563EB) : const Color(0xFFFF6584);
    return InkWell(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
          border: Border.all(color: isSelected ? color : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? color : Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppConstants.primaryBlue, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
