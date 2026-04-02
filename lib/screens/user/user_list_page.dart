// lib/screens/user/user_list_page.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/loading_button.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<dynamic> _users = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final res = await RemoteHelper.getDio().get('api/users');
      final data = (res.data['data'] as List<dynamic>?) ?? [];
      setState(() { _users = data; _filtered = data; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String q) {
    setState(() {
      _search = q.toLowerCase();
      _filtered = _users.where((u) =>
        (u['name'] ?? '').toLowerCase().contains(_search) ||
        (u['email'] ?? '').toLowerCase().contains(_search)
      ).toList();
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: AppTheme.fontFamily)),
      backgroundColor: isError ? AppTheme.error : AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.background,
      appBar: AppBar(
        title: const Text('User Management',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 16)),
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.surface,
        foregroundColor: isDark ? AppTheme.darkText : AppTheme.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Tambah User',
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? AppTheme.darkSurface : AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: SizedBox(
              height: 42,
              child: TextField(
                onChanged: _onSearch,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13,
                  color: isDark ? AppTheme.darkText : AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari user...',
                  prefixIcon: Icon(Icons.search_rounded, size: 18,
                    color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkSurfaceVar : AppTheme.background,
                ),
              ),
            ),
          ),
          Expanded(
            child: DataTableCard(
              isLoading: _isLoading,
              emptyMessage: 'Belum ada user',
              emptyIcon: Icons.manage_accounts_rounded,
              headers: const ['ID', 'NAMA', 'EMAIL', 'ROLE', 'AKSI'],
              rows: _filtered.map((u) {
                final isAdmin = (u['role'] ?? '') == 'ADMIN';
                return [
                  Text(u['id'] ?? '', style: TextStyle(fontFamily: AppTheme.fontFamily,
                    fontSize: 12, color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary)),
                  Row(children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                      child: Text((u['name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(u['name'] ?? '', style: TextStyle(
                      fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w500,
                      color: isDark ? AppTheme.darkText : AppTheme.textPrimary))),
                  ]),
                  Text(u['email'] ?? '', style: TextStyle(fontFamily: AppTheme.fontFamily,
                    fontSize: 12, color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary)),
                  StatusBadge(
                    label: u['role'] ?? '',
                    color: isAdmin ? AppTheme.primary : AppTheme.success,
                  ),
                  // Tombol Edit & Hapus
                  Row(children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18, color: AppTheme.primary),
                      tooltip: 'Edit',
                      onPressed: () => _showEditDialog(context, u),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, size: 18, color: AppTheme.error),
                      tooltip: 'Hapus',
                      onPressed: () => _showDeleteDialog(context, u),
                    ),
                  ]),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Create ───────────────────────────────────────────────────────────────
  void _showCreateDialog(BuildContext context) {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'PETUGAS';
    bool loading = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah User',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _field('ID', idCtrl, 'Contoh: EMP001'),
                const SizedBox(height: 12),
                _field('Nama', nameCtrl, 'Nama lengkap'),
                const SizedBox(height: 12),
                _field('Email', emailCtrl, 'email@contoh.com'),
                const SizedBox(height: 12),
                _field('Password', passCtrl, '••••••••', isPassword: true),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                    DropdownMenuItem(value: 'PETUGAS', child: Text('PETUGAS')),
                  ],
                  onChanged: (v) => setStateDialog(() => role = v ?? 'PETUGAS'),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            LoadingButton(
              isLoading: loading,
              text: 'Simpan',
              onPressed: () async {
                if (idCtrl.text.isEmpty || nameCtrl.text.isEmpty) {
                  _showSnack('ID dan Nama wajib diisi!', isError: true);
                  return;
                }
                // Cek duplikat ID
                final isDuplicate = _users.any((u) => u['id'] == idCtrl.text.trim());
                if (isDuplicate) {
                  _showSnack('ID "${idCtrl.text}" sudah ada!', isError: true);
                  return;
                }
                setStateDialog(() => loading = true);
                try {
                  await RemoteHelper.getDio().post('api/users', data: {
                    'id': idCtrl.text.trim(),
                    'name': nameCtrl.text,
                    'email': emailCtrl.text,
                    'password': passCtrl.text,
                    'role': role,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadUsers();
                  _showSnack('User berhasil ditambahkan!');
                } catch (_) {
                  setStateDialog(() => loading = false);
                  _showSnack('Gagal menambahkan user!', isError: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Edit ─────────────────────────────────────────────────────────────────
  void _showEditDialog(BuildContext context, Map<String, dynamic> user) {
    final nameCtrl = TextEditingController(text: user['name']);
    final emailCtrl = TextEditingController(text: user['email']);
    final passCtrl = TextEditingController();
    String role = user['role'] ?? 'PETUGAS';
    bool loading = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit User — ${user['id']}',
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _field('Nama', nameCtrl, 'Nama lengkap'),
                const SizedBox(height: 12),
                _field('Email', emailCtrl, 'email@contoh.com'),
                const SizedBox(height: 12),
                _field('Password Baru', passCtrl, 'Kosongkan jika tidak diubah', isPassword: true),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                    DropdownMenuItem(value: 'PETUGAS', child: Text('PETUGAS')),
                  ],
                  onChanged: (v) => setStateDialog(() => role = v ?? 'PETUGAS'),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            LoadingButton(
              isLoading: loading,
              text: 'Simpan',
              onPressed: () async {
                setStateDialog(() => loading = true);
                try {
                  final body = {
                    'name': nameCtrl.text,
                    'email': emailCtrl.text,
                    'role': role,
                  };
                  if (passCtrl.text.isNotEmpty) body['password'] = passCtrl.text;
                  await RemoteHelper.getDio().put('api/users/${user['id']}', data: body);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadUsers();
                  _showSnack('User berhasil diupdate!');
                } catch (_) {
                  setStateDialog(() => loading = false);
                  _showSnack('Gagal mengupdate user!', isError: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Delete ───────────────────────────────────────────────────────────────
  void _showDeleteDialog(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus User',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
        content: Text('Yakin ingin menghapus "${user['name']}"?',
          style: const TextStyle(fontFamily: AppTheme.fontFamily)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              try {
                await RemoteHelper.getDio().delete('api/users/${user['id']}');
                if (context.mounted) Navigator.pop(context);
                _loadUsers();
                _showSnack('User berhasil dihapus!');
              } catch (_) {
                if (context.mounted) Navigator.pop(context);
                _showSnack('Gagal menghapus user!', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint,
      {bool isPassword = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: isPassword,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13,
            color: isDark ? AppTheme.darkText : AppTheme.textPrimary),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}