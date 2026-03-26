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
      setState(() {
        _users = data;
        _filtered = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String q) {
    setState(() {
      _search = q.toLowerCase();
      _filtered = _users
          .where(
            (u) =>
                (u['name'] ?? '').toLowerCase().contains(_search) ||
                (u['email'] ?? '').toLowerCase().contains(_search),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.background;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Manajemen Petugas',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // ── Header: search + tombol tambah
      body: Column(
        children: [
          Container(
            color: isDark ? AppTheme.darkSurface : AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _onSearch,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      color: textColor,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Cari user...',
                      prefixIcon: Icon(Icons.search_rounded, size: 18),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      constraints: BoxConstraints(maxHeight: 42),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Tambah User'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Tabel
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: DataTableCard(
                isLoading: _isLoading,
                emptyMessage: 'Belum ada user',
                emptyIcon: Icons.manage_accounts_rounded,
                headers: const ['ID', 'NAMA', 'EMAIL', 'ROLE'],
                rows: _filtered.map((u) {
                  final isAdmin = (u['role'] ?? '') == 'ADMIN';
                  return [
                    Text(
                      u['id'] ?? '',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: subColor,
                      ),
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.surfaceVariant,
                          child: Text(
                            (u['name'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            u['name'] ?? '',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      u['email'] ?? '',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: subColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    StatusBadge(
                      label: u['role'] ?? '',
                      color: isAdmin ? AppTheme.primary : AppTheme.success,
                    ),
                  ];
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Tambah User',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      DropdownMenuItem(
                        value: 'PETUGAS',
                        child: Text('PETUGAS'),
                      ),
                    ],
                    onChanged: (v) =>
                        setStateDialog(() => role = v ?? 'PETUGAS'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            LoadingButton(
              isLoading: loading,
              text: 'Simpan',
              onPressed: () async {
                setStateDialog(() => loading = true);
                try {
                  await RemoteHelper.getDio().post(
                    'api/users',
                    data: {
                      'id': idCtrl.text,
                      'name': nameCtrl.text,
                      'email': emailCtrl.text,
                      'password': passCtrl.text,
                      'role': role,
                    },
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadUsers();
                } catch (_) {
                  setStateDialog(() => loading = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    String hint, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: isPassword,
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
