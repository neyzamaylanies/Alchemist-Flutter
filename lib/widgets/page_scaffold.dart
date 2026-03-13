// lib/widgets/page_scaffold.dart
// Reusable scaffold untuk semua list page dengan search + action button
// Updated: mobile friendly, dark mode support, hapus title (sudah ada di AppBar)
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PageScaffold extends StatelessWidget {
  final String title; // masih ada tapi tidak ditampilkan (backward compat)
  final Widget body;
  final String? searchHint;
  final ValueChanged<String>? onSearch;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Widget>? extraActions;

  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.searchHint,
    this.onSearch,
    this.actionLabel,
    this.onAction,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top action bar
        Container(
          color: isDark ? AppTheme.darkSurface : AppTheme.surface,
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 24,
            12,
            isMobile ? 16 : 24,
            12,
          ),
          child: isMobile
              ? _buildMobileBar(context, isDark)
              : _buildDesktopBar(context, isDark),
        ),
        Expanded(child: body),
      ],
    );
  }

  // Mobile: search bar full width di atas, tombol di bawahnya
  Widget _buildMobileBar(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (searchHint != null && onSearch != null) ...[
          _buildSearchField(isDark),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            if (extraActions != null) ...extraActions!,
            const Spacer(),
            if (actionLabel != null && onAction != null)
              _buildActionButton(),
          ],
        ),
      ],
    );
  }

  // Desktop: search bar + tombol dalam satu baris
  Widget _buildDesktopBar(BuildContext context, bool isDark) {
    return Row(
      children: [
        if (searchHint != null && onSearch != null)
          Expanded(child: _buildSearchField(isDark))
        else
          const Spacer(),
        if (extraActions != null) ...extraActions!,
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(width: 12),
          _buildActionButton(),
        ],
      ],
    );
  }

  Widget _buildSearchField(bool isDark) {
    return SizedBox(
      height: 42,
      child: TextField(
        onChanged: onSearch,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 13,
          color: isDark ? AppTheme.darkText : AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: searchHint,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
          filled: true,
          fillColor: isDark ? AppTheme.darkSurfaceVar : AppTheme.surface,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: onAction,
      icon: const Icon(Icons.add_rounded, size: 16),
      label: Text(
        actionLabel!,
        style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }
}