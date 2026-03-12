// lib/screens/category/category_list_page.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../widgets/page_scaffold.dart';
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

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Kategori',
      searchHint: 'Cari kategori...',
      onSearch: _onSearch,
      actionLabel: '+ Tambah Kategori',
      onAction: () => _showCreateDialog(context),
      body: DataTableCard(
        isLoading: _isLoading,
        emptyMessage: 'Belum ada kategori',
        emptyIcon: Icons.category_rounded,
        headers: const ['ID', 'NAMA KATEGORI', 'DESKRIPSI'],
        rows: _filtered.map((c) => [
          Text(c['id'] ?? '', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
          Text(c['categoryName'] ?? '', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(c['description'] ?? '-', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
        ]).toList(),
      ),
    );
  }

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
          title: const Text('Tambah Kategori', style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('ID Kategori', idCtrl, 'Contoh: CAT001'),
                const SizedBox(height: 12),
                _field('Nama Kategori', nameCtrl, 'Contoh: Elektronik'),
                const SizedBox(height: 12),
                _field('Deskripsi', descCtrl, 'Deskripsi kategori'),
              ],
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
                  await RemoteHelper.getDio().post('api/categories', data: {
                    'id': idCtrl.text,
                    'categoryName': nameCtrl.text,
                    'description': descCtrl.text,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadCategories();
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

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}