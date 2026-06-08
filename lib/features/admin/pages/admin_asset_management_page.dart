import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/admin_bottom_nav.dart';

class AdminAssetManagementPage extends StatefulWidget {
  const AdminAssetManagementPage({super.key});

  @override
  State<AdminAssetManagementPage> createState() => _AdminAssetManagementPageState();
}

class _AdminAssetManagementPageState extends State<AdminAssetManagementPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _assets = [];
  bool _isLoading = true;
  String _searchQuery = '';

  static const _satuanOptions = ['Pcs', 'Unit', 'Set', 'Buah', 'Lembar', 'Pasang', 'Kotak'];

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAssets() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getAssets(search: _searchQuery);
      if (response.statusCode == 200 && response.data != null) {
        dynamic raw = response.data;

        // If Dio returned a raw JSON string instead of a parsed Map, decode it
        if (raw is String) {
          try {
            raw = jsonDecode(raw);
          } catch (_) {}
        }

        List<dynamic> parsed = [];
        if (raw is List) {
          parsed = raw;
        } else if (raw is Map) {
          final inner = raw['data'];
          if (inner is List) parsed = inner;
        }

        setState(() => _assets = parsed);
      }
    } catch (e) {
      _showSnackBar('Gagal memuat data: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAssetForm({Map<String, dynamic>? existing}) {
    final isEdit = existing != null;
    final kodeCtrl = TextEditingController(text: existing?['kode'] ?? '');
    final namaCtrl = TextEditingController(text: existing?['nama'] ?? '');
    final jumlahCtrl = TextEditingController(text: '${existing?['jumlah'] ?? 0}');
    final keteranganCtrl = TextEditingController(text: existing?['keterangan'] ?? '');
    String selectedSatuan = existing?['satuan'] ?? 'Pcs';
    final formKey = GlobalKey<FormState>();

    // Auto-generate kode if adding new
    if (!isEdit && _assets.isNotEmpty) {
      final count = _assets.length + 1;
      kodeCtrl.text = 'AST-${count.toString().padLeft(3, '0')}';
    } else if (!isEdit) {
      kodeCtrl.text = 'AST-001';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEdit ? 'Edit Asset' : 'Tambah Asset Baru',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Kode
                  _buildFormField(
                    controller: kodeCtrl,
                    label: 'Kode Asset',
                    hint: 'cth: AST-001',
                    icon: Icons.qr_code,
                    validator: (v) => (v == null || v.isEmpty) ? 'Kode wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  // Nama
                  _buildFormField(
                    controller: namaCtrl,
                    label: 'Nama Barang',
                    hint: 'cth: Kursi Roda',
                    icon: Icons.inventory_2,
                    validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  // Jumlah + Satuan row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildFormField(
                          controller: jumlahCtrl,
                          label: 'Jumlah',
                          hint: '0',
                          icon: Icons.numbers,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Satuan',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedSatuan,
                              decoration: _inputDecoration('cth: Pcs', Icons.straighten),
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                              items: _satuanOptions
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (v) => setModalState(() => selectedSatuan = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Keterangan
                  _buildFormField(
                    controller: keteranganCtrl,
                    label: 'Keterangan (opsional)',
                    hint: 'Catatan tambahan...',
                    icon: Icons.notes,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(ctx);
                        await _submitAsset(
                          isEdit: isEdit,
                          id: existing?['id'],
                          kode: kodeCtrl.text.trim(),
                          nama: namaCtrl.text.trim(),
                          jumlah: int.tryParse(jumlahCtrl.text) ?? 0,
                          satuan: selectedSatuan,
                          keterangan: keteranganCtrl.text.trim(),
                        );
                      },
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah Asset',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitAsset({
    required bool isEdit,
    String? id,
    required String kode,
    required String nama,
    required int jumlah,
    required String satuan,
    required String keterangan,
  }) async {
    try {
      if (isEdit && id != null) {
        await _apiService.updateAsset(id, {
          'kode': kode,
          'nama': nama,
          'jumlah': jumlah,
          'satuan': satuan,
          'keterangan': keterangan.isEmpty ? null : keterangan,
        });
        _showSnackBar('Asset berhasil diperbarui');
      } else {
        await _apiService.createAsset(
          kode: kode,
          nama: nama,
          jumlah: jumlah,
          satuan: satuan,
          keterangan: keterangan.isEmpty ? null : keterangan,
        );
        _showSnackBar('Asset berhasil ditambahkan');
      }
      _fetchAssets();
    } catch (e) {
      _showSnackBar('Gagal: ${e.toString()}', isError: true);
    }
  }

  Future<void> _confirmDelete(String id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Asset', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Hapus "$nama"? Tindakan ini tidak dapat dibatalkan.',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus',
                style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteAsset(id);
        _showSnackBar('Asset berhasil dihapus');
        _fetchAssets();
      } catch (e) {
        _showSnackBar('Gagal menghapus: ${e.toString()}', isError: true);
      }
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          decoration: _inputDecoration(hint, icon),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
      prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppConstants.primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Color _kondisiColor(String kondisi) {
    switch (kondisi) {
      case 'BAIK': return const Color(0xFF10B981);
      case 'RUSAK': return const Color(0xFFEF4444);
      default: return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppConstants.primaryBlue),
        title: Text(
          'Manajemen Asset',
          style: GoogleFonts.poppins(
            color: AppConstants.primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAssets),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 4),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAssetForm,
        backgroundColor: AppConstants.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Asset',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Summary bar
          if (!_isLoading)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildSummaryChip('Total', '${_assets.length}', AppConstants.primaryBlue),
                ],
              ),
            ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama atau kode asset...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _fetchAssets();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppConstants.primaryBlue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
              onChanged: (v) {
                setState(() => _searchQuery = v);
                _fetchAssets();
              },
            ),
          ),
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _assets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada data asset',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tekan "Tambah Asset" untuk mulai mencatat',
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: _assets.length,
                        itemBuilder: (context, index) {
                          final asset = _assets[index];
                          final String id = asset['id'] ?? '';
                          final String kode = asset['kode'] ?? '';
                          final String nama = asset['nama'] ?? '';
                          final int jumlah = int.tryParse(asset['jumlah']?.toString() ?? '0') ?? 0;
                          final String satuan = asset['satuan'] ?? '';
                          final String keterangan = asset['keterangan'] ?? '';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Kode badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          kode,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppConstants.primaryBlue,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      // Edit button
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blueGrey),
                                        onPressed: () => _showAssetForm(existing: asset),
                                        splashRadius: 20,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      // Delete button
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                        onPressed: () => _confirmDelete(id, nama),
                                        splashRadius: 20,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    nama,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  if (keterangan.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      keterangan,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.inventory, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Jumlah:',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$jumlah $satuan',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}
