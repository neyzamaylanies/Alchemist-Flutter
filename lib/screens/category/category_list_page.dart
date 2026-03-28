// lib/screens/category/category_list_page.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/loading_button.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<dynamic> _categories = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final res = await RemoteHelper.getDio().get('api/categories');
      final data = (res.data['data'] as List<dynamic>?) ?? [];
      setState(() { _categories = data; _filtered = data; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String q) {
    setState(() {
      _search = q.toLowerCase();
      _filtered = _categories.where((c) =>
        (c['categoryName'] ?? '').toLowerCase().contains(_search) ||
        (c['id'] ?? '').toLowerCase().contains(_search)
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
        title: const Text('Kategori',
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
              label: const Text('Tambah',
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
                  hintText: 'Cari kategori...',
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
              emptyMessage: 'Belum ada kategori',
              emptyIcon: Icons.category_rounded,
              headers: const ['ID', 'NAMA KATEGORI', 'DESKRIPSI', 'AKSI'],
              rows: _filtered.map((c) => [
                Text(c['id'] ?? '', style: TextStyle(fontFamily: AppTheme.fontFamily,
                  fontSize: 12, color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary)),
                Text(c['categoryName'] ?? '', style: TextStyle(fontFamily: AppTheme.fontFamily,
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkText : AppTheme.textPrimary)),
                Text(c['description'] ?? '-', style: TextStyle(fontFamily: AppTheme.fontFamily,
                  fontSize: 12, color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary)),
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18, color: AppTheme.primary),
                    tooltip: 'Edit',
                    onPressed: () => _showEditDialog(context, c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded, size: 18, color: AppTheme.error),
                    tooltip: 'Hapus',
                    onPressed: () => _showDeleteDialog(context, c),
                  ),
                ]),
              ]).toList(),
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
    final descCtrl = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah Kategori',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 400,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _field('ID Kategori', idCtrl, 'Contoh: CAT001'),
              const SizedBox(height: 12),
              _field('Nama Kategori', nameCtrl, 'Contoh: Elektronik'),
              const SizedBox(height: 12),
              _field('Deskripsi', descCtrl, 'Deskripsi kategori'),
            ]),
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
                final isDuplicate = _categories.any((c) => c['id'] == idCtrl.text.trim());
                if (isDuplicate) {
                  _showSnack('ID "${idCtrl.text}" sudah ada!', isError: true);
                  return;
                }
                setStateDialog(() => loading = true);
                try {
                  await RemoteHelper.getDio().post('api/categories', data: {
                    'id': idCtrl.text.trim(),
                    'categoryName': nameCtrl.text,
                    'description': descCtrl.text,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadCategories();
                  _showSnack('Kategori berhasil ditambahkan!');
                } catch (_) {
                  setStateDialog(() => loading = false);
                  _showSnack('Gagal menambahkan kategori!', isError: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Edit ─────────────────────────────────────────────────────────────────
  void _showEditDialog(BuildContext context, Map<String, dynamic> cat) {
    final nameCtrl = TextEditingController(text: cat['categoryName']);
    final descCtrl = TextEditingController(text: cat['description']);
    bool loading = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Kategori — ${cat['id']}',
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 400,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _field('Nama Kategori', nameCtrl, 'Nama kategori'),
              const SizedBox(height: 12),
              _field('Deskripsi', descCtrl, 'Deskripsi kategori'),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            LoadingButton(
              isLoading: loading,
              text: 'Simpan',
              onPressed: () async {
                setStateDialog(() => loading = true);
                try {
                  await RemoteHelper.getDio().put('api/categories/${cat['id']}', data: {
                    'categoryName': nameCtrl.text,
                    'description': descCtrl.text,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadCategories();
                  _showSnack('Kategori berhasil diupdate!');
                } catch (_) {
                  setStateDialog(() => loading = false);
                  _showSnack('Gagal mengupdate kategori!', isError: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Delete ───────────────────────────────────────────────────────────────
  void _showDeleteDialog(BuildContext context, Map<String, dynamic> cat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Kategori',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
        content: Text('Yakin ingin menghapus "${cat['categoryName']}"?',
          style: const TextStyle(fontFamily: AppTheme.fontFamily)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              try {
                await RemoteHelper.getDio().delete('api/categories/${cat['id']}');
                if (context.mounted) Navigator.pop(context);
                _loadCategories();
                _showSnack('Kategori berhasil dihapus!');
              } catch (_) {
                if (context.mounted) Navigator.pop(context);
                _showSnack('Gagal menghapus kategori!', isError: true);
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

  Widget _field(String label, TextEditingController ctrl, String hint) {
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
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13,
            color: isDark ? AppTheme.darkText : AppTheme.textPrimary),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}