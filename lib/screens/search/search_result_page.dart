// lib/screens/search/search_result_page.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';

class SearchResultPage extends StatefulWidget {
  final String initialQuery;
  const SearchResultPage({super.key, this.initialQuery = ''});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  List<dynamic> _equipments  = [];
  List<dynamic> _students    = [];
  List<dynamic> _transactions = [];
  List<dynamic> _categories  = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) _doSearch(widget.initialQuery);
  }

  Future<void> _doSearch(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        _equipments = []; _students = [];
        _transactions = []; _categories = [];
      });
      return;
    }
    setState(() => _isSearching = true);
    final query = q.toLowerCase();
    try {
      final results = await Future.wait([
        RemoteHelper.getDio().get('api/equipments'),
        RemoteHelper.getDio().get('api/students'),
        RemoteHelper.getDio().get('api/transactions'),
        RemoteHelper.getDio().get('api/categories'),
      ]);

      final eqs  = (results[0].data['data'] as List<dynamic>?) ?? [];
      final stus = (results[1].data['data'] as List<dynamic>?) ?? [];
      final trxs = (results[2].data['data'] as List<dynamic>?) ?? [];
      final cats = (results[3].data['data'] as List<dynamic>?) ?? [];

      setState(() {
        _equipments  = eqs.where((e) =>
          (e['equipmentName'] ?? '').toLowerCase().contains(query) ||
          (e['id'] ?? '').toLowerCase().contains(query) ||
          (e['location'] ?? '').toLowerCase().contains(query)
        ).toList();
        _students    = stus.where((s) =>
          (s['name'] ?? '').toLowerCase().contains(query) ||
          (s['nim'] ?? '').toLowerCase().contains(query) ||
          (s['studyProgram'] ?? '').toLowerCase().contains(query)
        ).toList();
        _transactions = trxs.where((t) =>
          (t['id'] ?? '').toLowerCase().contains(query) ||
          (t['equipmentId'] ?? '').toLowerCase().contains(query)
        ).toList();
        _categories  = cats.where((c) =>
          (c['categoryName'] ?? '').toLowerCase().contains(query) ||
          (c['id'] ?? '').toLowerCase().contains(query)
        ).toList();
        _isSearching = false;
      });
    } catch (_) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? AppTheme.darkBg : AppTheme.background;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    final total = _equipments.length + _students.length + _transactions.length + _categories.length;
    final hasQuery = _searchCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          onChanged: (q) {
            if (q.length >= 2) _doSearch(q);
            else if (q.isEmpty) _doSearch('');
          },
          onSubmitted: _doSearch,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: textColor),
          decoration: InputDecoration(
            hintText: 'Cari peralatan, mahasiswa, transaksi...',
            hintStyle: TextStyle(color: subColor, fontSize: 14),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_searchCtrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _searchCtrl.clear();
                _doSearch('');
              },
            ),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : !hasQuery
              ? _buildEmptySearch(isDark, subColor)
              : total == 0
                  ? _buildNoResult(isDark, subColor)
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_equipments.isNotEmpty) ...[
                          _SectionTitle(title: 'Peralatan', count: _equipments.length, isDark: isDark),
                          ..._equipments.map((e) => _ResultTile(
                            icon: Icons.science_rounded,
                            iconColor: AppTheme.primary,
                            title: e['equipmentName'] ?? '',
                            subtitle: '${e['id']} • ${e['location'] ?? ''}',
                            isDark: isDark,
                          )),
                          const SizedBox(height: 16),
                        ],
                        if (_students.isNotEmpty) ...[
                          _SectionTitle(title: 'Mahasiswa', count: _students.length, isDark: isDark),
                          ..._students.map((s) => _ResultTile(
                            icon: Icons.school_rounded,
                            iconColor: AppTheme.blueDeep,
                            title: s['name'] ?? '',
                            subtitle: '${s['nim']} • ${s['studyProgram'] ?? ''}',
                            isDark: isDark,
                          )),
                          const SizedBox(height: 16),
                        ],
                        if (_transactions.isNotEmpty) ...[
                          _SectionTitle(title: 'Transaksi', count: _transactions.length, isDark: isDark),
                          ..._transactions.map((t) => _ResultTile(
                            icon: Icons.swap_horiz_rounded,
                            iconColor: t['transactionType'] == 'OUT' ? AppTheme.warning : AppTheme.success,
                            title: t['id'] ?? '',
                            subtitle: '${t['transactionType']} • Alat: ${t['equipmentId']}',
                            isDark: isDark,
                          )),
                          const SizedBox(height: 16),
                        ],
                        if (_categories.isNotEmpty) ...[
                          _SectionTitle(title: 'Kategori', count: _categories.length, isDark: isDark),
                          ..._categories.map((c) => _ResultTile(
                            icon: Icons.category_rounded,
                            iconColor: AppTheme.purpleMid,
                            title: c['categoryName'] ?? '',
                            subtitle: c['id'] ?? '',
                            isDark: isDark,
                          )),
                        ],
                      ],
                    ),
    );
  }

  Widget _buildEmptySearch(bool isDark, Color subColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 64,
            color: isDark ? AppTheme.darkTextSub : AppTheme.textMuted),
          const SizedBox(height: 12),
          Text('Ketik untuk mulai mencari', style: TextStyle(
            fontFamily: AppTheme.fontFamily, color: subColor, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNoResult(bool isDark, Color subColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64,
            color: isDark ? AppTheme.darkTextSub : AppTheme.textMuted),
          const SizedBox(height: 12),
          Text('Tidak ada hasil untuk "${_searchCtrl.text}"',
            style: TextStyle(fontFamily: AppTheme.fontFamily, color: subColor, fontSize: 14)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  final bool isDark;
  const _SectionTitle({required this.title, required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title, style: TextStyle(
            fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700,
            fontSize: 13, color: isDark ? AppTheme.darkText : AppTheme.textPrimary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: const TextStyle(
              fontFamily: AppTheme.fontFamily, fontSize: 11,
              fontWeight: FontWeight.w600, color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  const _ResultTile({required this.icon, required this.iconColor,
    required this.title, required this.subtitle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600,
                  fontSize: 13, color: isDark ? AppTheme.darkText : AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(
                  fontFamily: AppTheme.fontFamily, fontSize: 11,
                  color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14,
            color: isDark ? AppTheme.darkTextSub : AppTheme.textMuted),
        ],
      ),
    );
  }
}