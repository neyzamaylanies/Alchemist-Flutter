// lib/screens/user/user_list_page.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../widgets/data_table_card.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});
  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<dynamic> _users    = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String _search  = '';

  @override
  void initState() { super.initState(); _loadUsers(); }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final res  = await RemoteHelper.getDio().get('api/users');
      final data = (res.data['data'] as List<dynamic>?) ?? [];
      setState(() { _users = data; _filtered = data; _isLoading = false; });
    } catch (_) { setState(() => _isLoading = false); }
  }

  void _onSearch(String q) {
    setState(() {
      _search   = q.toLowerCase();
      _filtered = _users.where((u) =>
        (u['name'] ?? '').toLowerCase().contains(_search) ||
        (u['email'] ?? '').toLowerCase().contains(_search)).toList();
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

  String _nextId(String role) {
    final prefix = role == 'ADMIN' ? 'ADM' : 'EMP';
    int max = 0;
    for (final item in _users) {
      final id = (item['id'] ?? '') as String;
      if (id.startsWith(prefix)) {
        final num = int.tryParse(id.substring(prefix.length)) ?? 0;
        if (num > max) max = num;
      }
    }
    return '$prefix${(max + 1).toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.background,
      appBar: AppBar(
        title: const Text('Data Petugas',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 16)),
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        foregroundColor: isDark ? AppTheme.darkText : AppTheme.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _showCreateBottomSheet(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Tambah Petugas',
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Container(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: TextField(
            onChanged: _onSearch,
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
            decoration: InputDecoration(
              hintText: 'Cari petugas...',
              prefixIcon: Icon(Icons.search_rounded, size: 18, color: subColor),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              constraints: const BoxConstraints(maxHeight: 42),
              filled: true,
              fillColor: isDark ? AppTheme.darkSurfaceVar : AppTheme.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
            ),
          ),
        ),
        Expanded(child: DataTableCard(
          isLoading: _isLoading,
          emptyMessage: 'Belum ada petugas',
          emptyIcon: Icons.manage_accounts_rounded,
          headers: const ['ID', 'NAMA', 'EMAIL', 'ROLE', 'AKSI'],
          rows: _filtered.map((u) {
            final isAdmin = (u['role'] ?? '') == 'ADMIN';
            return [
              Text(u['id'] ?? '', style: TextStyle(fontFamily: AppTheme.fontFamily,
                fontSize: 12, color: subColor)),
              Row(children: [
                CircleAvatar(radius: 14,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                  child: Text((u['name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                Expanded(child: Text(u['name'] ?? '', style: TextStyle(
                  fontFamily: AppTheme.fontFamily, fontSize: 13,
                  fontWeight: FontWeight.w500, color: textColor))),
              ]),
              Text(u['email'] ?? '', style: TextStyle(fontFamily: AppTheme.fontFamily,
                fontSize: 12, color: subColor)),
              StatusBadge(label: u['role'] ?? '',
                color: isAdmin ? AppTheme.primary : AppTheme.success),
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18, color: AppTheme.primary),
                  tooltip: 'Edit',
                  onPressed: () => _showEditBottomSheet(context, u),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, size: 18, color: AppTheme.error),
                  tooltip: 'Hapus',
                  onPressed: () => _showDeleteDialog(context, u),
                ),
              ]),
            ];
          }).toList(),
        )),
      ]),
    );
  }

  // ── Helpers bottom sheet ──────────────────────────────────────────────────

  InputDecoration _fieldDeco({
    required String hint,
    required bool isDark,
  }) {
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13,
        color: isDark ? AppTheme.darkTextSub : const Color(0xFFB0B0C0)),
      filled: true,
      fillColor: isDark ? AppTheme.darkSurfaceVar : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
    );
  }

  Widget _sheetLabel(String text, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: TextStyle(fontFamily: AppTheme.fontFamily,
      fontSize: 12, fontWeight: FontWeight.w500, color: color)),
  );

  Widget _readOnlyBox(String value, bool isDark) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      color: isDark ? AppTheme.darkSurfaceVar : const Color(0xFFF0F0F8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0)),
    ),
    child: Text(value, style: const TextStyle(fontFamily: AppTheme.fontFamily,
      fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
  );

  // ── Create ────────────────────────────────────────────────────────────────
  void _showCreateBottomSheet(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0);
    final fillColor   = isDark ? AppTheme.darkSurfaceVar : Colors.white;

    String role      = 'PETUGAS';
    String genId     = _nextId(role);
    final nameCtrl   = TextEditingController();
    final emailCtrl  = TextEditingController();
    final passCtrl   = TextEditingController();
    bool loading     = false;
    bool obscurePass = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFE0E0E8),
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Tambah Petugas', style: TextStyle(fontFamily: AppTheme.fontFamily,
                fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
              const SizedBox(height: 20),

              // Role (pilih dulu agar ID menyesuaikan)
              _sheetLabel('Role', subColor),
              DropdownButtonFormField<String>(
                value: role,
                decoration: InputDecoration(
                  filled: true, fillColor: fillColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                ),
                items: [
                  DropdownMenuItem(value: 'ADMIN',
                    child: Text('ADMIN', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor))),
                  DropdownMenuItem(value: 'PETUGAS',
                    child: Text('PETUGAS', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor))),
                ],
                onChanged: (v) => setS(() { role = v ?? 'PETUGAS'; genId = _nextId(role); }),
              ),
              const SizedBox(height: 14),

              // ID (read-only, auto-update saat role berubah)
              _sheetLabel('ID (otomatis)', subColor),
              _readOnlyBox(genId, isDark),
              const SizedBox(height: 14),

              // Nama
              _sheetLabel('Nama', subColor),
              TextField(controller: nameCtrl,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                decoration: _fieldDeco(hint: 'Nama lengkap', isDark: isDark)),
              const SizedBox(height: 14),

              // Email
              _sheetLabel('Email', subColor),
              TextField(controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                decoration: _fieldDeco(hint: 'email@contoh.com', isDark: isDark)),
              const SizedBox(height: 14),

              // Password
              _sheetLabel('Password', subColor),
              TextField(
                controller: passCtrl,
                obscureText: obscurePass,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                decoration: _fieldDeco(hint: '••••••••', isDark: isDark).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 18, color: subColor),
                    onPressed: () => setS(() => obscurePass = !obscurePass),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Batal',
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: loading ? null : () async {
                    if (nameCtrl.text.isEmpty) {
                      _showSnack('Nama wajib diisi!', isError: true); return;
                    }
                    setS(() => loading = true);
                    try {
                      await RemoteHelper.getDio().post('api/users', data: {
                        'id': genId, 'name': nameCtrl.text,
                        'email': emailCtrl.text, 'password': passCtrl.text, 'role': role,
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadUsers();
                      _showSnack('Petugas berhasil ditambahkan!');
                    } catch (_) {
                      setS(() => loading = false);
                      _showSnack('Gagal menambahkan!', isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan',
                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 14)),
                )),
              ]),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Edit ──────────────────────────────────────────────────────────────────
  void _showEditBottomSheet(BuildContext context, Map<String, dynamic> user) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0);
    final fillColor   = isDark ? AppTheme.darkSurfaceVar : Colors.white;

    final nameCtrl  = TextEditingController(text: user['name'] ?? '');
    final emailCtrl = TextEditingController(text: user['email'] ?? '');
    final passCtrl  = TextEditingController();
    String role     = user['role'] ?? 'PETUGAS';
    bool loading    = false;
    bool obscurePass = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFE0E0E8),
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Edit Petugas', style: TextStyle(fontFamily: AppTheme.fontFamily,
                fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
              const SizedBox(height: 20),

              // ID read-only
              _sheetLabel('ID', subColor),
              _readOnlyBox(user['id'] ?? '', isDark),
              const SizedBox(height: 14),

              // Nama
              _sheetLabel('Nama', subColor),
              TextField(controller: nameCtrl,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                decoration: _fieldDeco(hint: 'Nama lengkap', isDark: isDark)),
              const SizedBox(height: 14),

              // Email
              _sheetLabel('Email', subColor),
              TextField(controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                decoration: _fieldDeco(hint: 'email@contoh.com', isDark: isDark)),
              const SizedBox(height: 14),

              // Password baru (opsional)
              _sheetLabel('Password Baru (opsional)', subColor),
              TextField(
                controller: passCtrl,
                obscureText: obscurePass,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                decoration: _fieldDeco(hint: 'Kosongkan jika tidak diubah', isDark: isDark).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 18, color: subColor),
                    onPressed: () => setS(() => obscurePass = !obscurePass),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Role
              _sheetLabel('Role', subColor),
              DropdownButtonFormField<String>(
                value: role,
                decoration: InputDecoration(
                  filled: true, fillColor: fillColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                ),
                items: [
                  DropdownMenuItem(value: 'ADMIN',
                    child: Text('ADMIN', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor))),
                  DropdownMenuItem(value: 'PETUGAS',
                    child: Text('PETUGAS', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor))),
                ],
                onChanged: (v) => setS(() => role = v ?? 'PETUGAS'),
              ),
              const SizedBox(height: 24),

              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Batal',
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: loading ? null : () async {
                    setS(() => loading = true);
                    try {
                      final body = {'name': nameCtrl.text, 'email': emailCtrl.text, 'role': role};
                      if (passCtrl.text.isNotEmpty) body['password'] = passCtrl.text;
                      await RemoteHelper.getDio().put('api/users/${user['id']}', data: body);
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadUsers();
                      _showSnack('Petugas berhasil diupdate!');
                    } catch (_) {
                      setS(() => loading = false);
                      _showSnack('Gagal mengupdate!', isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan',
                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 14)),
                )),
              ]),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Petugas',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
        content: Text('Yakin ingin menghapus "${user['name']}"?',
          style: const TextStyle(fontFamily: AppTheme.fontFamily)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await RemoteHelper.getDio().delete('api/users/${user['id']}');
                _loadUsers();
                _showSnack('Petugas berhasil dihapus!');
              } catch (_) {
                _showSnack('Gagal menghapus!', isError: true);
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
}