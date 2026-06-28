import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/admin_bottom_nav.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../providers/admin_users_provider.dart';

class AdminUserManagementPage extends ConsumerStatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  ConsumerState<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends ConsumerState<AdminUserManagementPage> {
  int _selectedTab = 0; // 0 = Semua, 1 = Orang Tua, 2 = Terapis
  final List<String> _tabs = ['Semua', 'Orang Tua', 'Terapis'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredUsers {
    final users = ref.watch(adminUsersProvider).users;
    return users.where((user) {
      final name = user['name']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      final matchesSearch = name.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase());
      final role = user['role']?.toString() ?? '';
      if (role == 'ADMIN') return false;
      final matchesTab = _selectedTab == 0 ||
          (_selectedTab == 1 && role == 'PARENT') ||
          (_selectedTab == 2 && role == 'THERAPIST');
      return matchesSearch && matchesTab;
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
      ref.read(adminUsersProvider.notifier).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);
    final filteredUsers = _filteredUsers;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(state),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: state.isLoading
                ? const Center(child: LoadingWidget())
                : filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : _buildUserList(filteredUsers),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }

  PreferredSizeWidget _buildAppBar(AdminUsersState state) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manajemen Pengguna',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              fontSize: 16,
            ),
          ),
          Text(
            '${state.total} pengguna ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
      actions: [
        if (_selectedTab == 2)
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppConstants.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_add_alt_1, size: 20, color: AppConstants.primaryBlue),
              onPressed: _showAddTherapistDialog,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Cari nama atau email...',
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
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      color: Colors.white,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child:             GestureDetector(
              onTap: () {
                setState(() => _selectedTab = index);
                final role = index == 1 ? 'PARENT' : (index == 2 ? 'THERAPIST' : null);
                ref.read(adminUsersProvider.notifier).fetchUsers(role: role);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppConstants.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isParent = user['role'] == 'PARENT';
    final isBlocked = user['isBlocked'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: isBlocked ? Border.all(color: const Color(0xFFEF4444), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ProfileAvatar(name: user['name']?.toString() ?? '', radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['name']?.toString() ?? '-',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isBlocked ? const Color(0xFFEF4444) : const Color(0xFF111827),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isParent
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                            : const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isParent ? 'Orang Tua' : 'Terapis',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isParent ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user['email']?.toString() ?? '-',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bergabung: ${user['createdAt']?.toString().substring(0, 10) ?? '-'}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF6B7280)),
            onSelected: (value) => _handleMenuAction(value, user),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'detail',
                child: Row(
                  children: [
                    const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Text('Lihat Detail', style: GoogleFonts.poppins(fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever_outlined,
                      size: 18,
                      color: const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hapus Akun',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada user ditemukan',
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

  void _handleMenuAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'detail':
        _showUserDetailDialog(user);
        break;
      case 'delete':
        _showDeleteConfirmDialog(user);
        break;
    }
  }

  void _showUserDetailDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Detail Pengguna', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nama', user['name']?.toString() ?? '-'),
            _buildDetailRow('Email', user['email']?.toString() ?? '-'),
            _buildDetailRow('Peran', user['role'] == 'PARENT' ? 'Orang Tua' : 'Terapis'),
            _buildDetailRow('Status', user['isBlocked'] ? 'Diblokir' : 'Aktif'),
            _buildDetailRow('Bergabung', user['createdAt']?.toString().substring(0, 10) ?? '-'),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280)),
            ),
          ),
          Text(
            ':',
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> user) {
    final role = user['role'] == 'THERAPIST' ? 'Terapis' : 'Orang Tua';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
            const SizedBox(width: 8),
            Text('Hapus Akun?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFFEF4444))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Akun $role "${user['name']}" akan dihapus secara permanen.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua data terkait akun ini tidak dapat dikembalikan.',
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFEF4444), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins(color: const Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(adminUsersProvider.notifier).manageUser(
                userId: user['id'],
                action: 'delete',
              );
              if (success) {
                ref.read(adminUsersProvider.notifier).fetchUsers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Akun ${user['name']} berhasil dihapus'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus akun'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Hapus Permanen', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAddTherapistDialog() {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final passwordC = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Tambah Terapis', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    labelStyle: GoogleFonts.poppins(fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.poppins(fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordC,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.poppins(fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.poppins(color: const Color(0xFF6B7280))),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (nameC.text.trim().isEmpty || emailC.text.trim().isEmpty || passwordC.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Harap isi semua field'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      setDialogState(() => loading = true);
                      try {
                        final api = ApiService();
                        final response = await api.createAdminUser(
                          name: nameC.text.trim(),
                          email: emailC.text.trim(),
                          password: passwordC.text.trim(),
                        );
                        if (response.statusCode == 201) {
                          Navigator.pop(ctx);
                          ref.read(adminUsersProvider.notifier).fetchUsers();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Terapis berhasil ditambahkan'), backgroundColor: Colors.green),
                          );
                        } else {
                          final msg = response.data is Map ? response.data['message'] ?? 'Gagal menambahkan terapis' : 'Gagal menambahkan terapis';
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                      }
                      if (ctx.mounted) setDialogState(() => loading = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Tambah', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
