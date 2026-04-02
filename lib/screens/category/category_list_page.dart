// lib/screens/category/category_list_page.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../widgets/data_table_card.dart';

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
      setState(() {
        _categories = data;
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
      _filtered = _categories
          .where(
            (c) =>
                (c['categoryName'] ?? '').toLowerCase().contains(_search) ||
                (c['id'] ?? '').toLowerCase().contains(_search),
          )
          .toList();
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _nextId() {
    const prefix = 'CAT';
    int max = 0;
    for (final item in _categories) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Kategori',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        foregroundColor: isDark ? AppTheme.darkText : AppTheme.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _showFormBottomSheet(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'Tambah',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              onChanged: _onSearch,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Cari kategori...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: subColor,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                constraints: const BoxConstraints(maxHeight: 42),
                filled: true,
                fillColor: isDark
                    ? AppTheme.darkSurfaceVar
                    : AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppTheme.darkBorder
                        : const Color(0xFFE8E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppTheme.darkBorder
                        : const Color(0xFFE8E8F0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 1.5,
                  ),
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
              rows: _filtered
                  .map(
                    (c) => [
                      Text(
                        c['id'] ?? '',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: subColor,
                        ),
                      ),
                      Text(
                        c['categoryName'] ?? '',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        c['description'] ?? '-',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: subColor,
                        ),
                      ),
                      Row(
                        children: [
                          ActionButton(
                            icon: Icons.edit_rounded,
                            color: AppTheme.primary,
                            tooltip: 'Edit',
                            onTap: () => _showFormBottomSheet(context, cat: c),
                          ),
                          const SizedBox(width: 6),
                          ActionButton(
                            icon: Icons.delete_rounded,
                            color: AppTheme.error,
                            tooltip: 'Hapus',
                            onTap: () => _showDeleteDialog(context, c),
                          ),
                        ],
                      ),
                    ],
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form bottom sheet (Create & Edit) ──────────────────────────────────────
  void _showFormBottomSheet(BuildContext context, {Map<String, dynamic>? cat}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCreate = cat == null;
    final generatedId = isCreate ? _nextId() : (cat!['id'] ?? '');
    final nameCtrl = TextEditingController(
      text: isCreate ? '' : cat!['categoryName'] ?? '',
    );
    final descCtrl = TextEditingController(
      text: isCreate ? '' : cat!['description'] ?? '',
    );
    bool loading = false;

    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0);
    final fillColor = isDark ? AppTheme.darkSurfaceVar : Colors.white;
    final subColor = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkBorder
                          : const Color(0xFFE0E0E8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isCreate ? 'Tambah Kategori' : 'Edit Kategori',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),

                // ID (read-only)
                Text(
                  'ID Kategori',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurfaceVar
                        : const Color(0xFFF0F0F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    generatedId,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Nama Kategori
                Text(
                  'Nama Kategori',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subColor,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Elektronik',
                    hintStyle: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      color: subColor,
                    ),
                    filled: true,
                    fillColor: fillColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Deskripsi
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subColor,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Deskripsi kategori (opsional)',
                    hintStyle: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      color: subColor,
                    ),
                    filled: true,
                    fillColor: fillColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading
                            ? null
                            : () async {
                                if (nameCtrl.text.isEmpty) {
                                  _showSnack(
                                    'Nama wajib diisi!',
                                    isError: true,
                                  );
                                  return;
                                }
                                setS(() => loading = true);
                                try {
                                  if (isCreate) {
                                    await RemoteHelper.getDio().post(
                                      'api/categories',
                                      data: {
                                        'id': generatedId,
                                        'categoryName': nameCtrl.text,
                                        'description': descCtrl.text,
                                      },
                                    );
                                    _showSnack(
                                      'Kategori berhasil ditambahkan!',
                                    );
                                  } else {
                                    await RemoteHelper.getDio().put(
                                      'api/categories/$generatedId',
                                      data: {
                                        'categoryName': nameCtrl.text,
                                        'description': descCtrl.text,
                                      },
                                    );
                                    _showSnack('Kategori berhasil diupdate!');
                                  }
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  _loadCategories();
                                } catch (_) {
                                  setS(() => loading = false);
                                  _showSnack(
                                    isCreate
                                        ? 'Gagal menambahkan!'
                                        : 'Gagal mengupdate!',
                                    isError: true,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isCreate ? 'Tambah' : 'Simpan',
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> cat) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Kategori',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus "${cat['categoryName']}"?',
          style: const TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await RemoteHelper.getDio().delete(
                  'api/categories/${cat['id']}',
                );
                _loadCategories();
                _showSnack('Kategori berhasil dihapus!');
              } catch (_) {
                _showSnack('Gagal menghapus!', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
