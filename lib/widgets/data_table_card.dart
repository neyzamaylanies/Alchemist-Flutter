// lib/widgets/data_table_card.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DataTableCard — Responsive table widget
//
// • Desktop (≥600px): header + body dalam SATU SingleChildScrollView horizontal
//   → header & baris SELALU sinkron saat scroll.
//   → Kolom melar mengisi lebar layar kalau total kolom < lebar layar.
//   → Scroll horizontal muncul otomatis kalau total kolom > lebar layar.
//
// • Mobile (<600px): card list vertikal dengan label-value rows.
//   → Tidak ada overflow sama sekali karena Expanded menyerap sisa lebar.
// ─────────────────────────────────────────────────────────────────────────────
class DataTableCard extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;
  final bool isLoading;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<double>? columnWidths;

  const DataTableCard({
    super.key,
    required this.headers,
    required this.rows,
    this.isLoading = false,
    this.emptyMessage = 'Belum ada data',
    this.emptyIcon = Icons.inbox_rounded,
    this.columnWidths,
  });

  double _defaultWidth(String header) {
    switch (header.toUpperCase()) {
      case 'ID':
        return 110;
      case 'AKSI':
        return 90;
      case 'JUMLAH':
        return 80;
      case 'PETUGAS':
        return 100;
      case 'PEMINJAM':
        return 110;
      case 'TANGGAL':
        return 120;
      case 'TIPE':
        return 120;
      case 'TERSEDIA':
        return 90;
      case 'TOTAL':
        return 80;
      case 'STATUS':
        return 130;
      case 'LOKASI':
        return 140;
      case 'NAMA':
      case 'NAMA KATEGORI':
        return 160;
      case 'PROGRAM STUDI':
        return 150;
      case 'EMAIL':
        return 180;
      case 'ROLE':
        return 100;
      case 'NIM':
        return 120;
      case 'NO. HP':
        return 120;
      case 'KATEGORI':
        return 120;
      case 'LOG ID':
        return 140;
      case 'ALAT':
        return 110;
      case 'SEBELUM':
      case 'SESUDAH':
        return 120;
      case 'TGL CEK':
        return 110;
      case 'DICEK OLEH':
        return 110;
      case 'DESKRIPSI':
        return 180;
      default:
        return 130;
    }
  }

  List<double> get _baseWidths {
    if (columnWidths != null && columnWidths!.length == headers.length) {
      return columnWidths!;
    }
    return headers.map(_defaultWidth).toList();
  }

  double get _minTotalWidth => _baseWidths.fold(0.0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppTheme.darkSurface : AppTheme.surface;
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Pakai lebar actual widget, bukan lebar layar
        final availableWidth = constraints.maxWidth;
        final isMobile = availableWidth < 600;

        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: _buildBody(
              context,
              isDark,
              isMobile,
              borderColor,
              availableWidth,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool isDark,
    bool isMobile,
    Color borderColor,
    double screenWidth,
  ) {
    if (isLoading) return _buildLoading();
    if (rows.isEmpty) return _buildEmpty(isDark);
    if (isMobile) return _buildMobileList(isDark, borderColor);
    return _buildDesktopTable(isDark, borderColor, screenWidth);
  }

  // ── Loading ──────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  // ── Empty ────────────────────────────────────────────────────────────────
  Widget _buildEmpty(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              emptyIcon,
              size: 44,
              color: isDark ? AppTheme.darkTextSub : AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: isDark ? AppTheme.darkTextSub : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile card list ─────────────────────────────────────────────────────
  Widget _buildMobileList(bool isDark, Color borderColor) {
    final cardBg = isDark ? const Color(0xFF1A1730) : Colors.white;
    final labelColor = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(headers.length, (i) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i < headers.length - 1 ? 8 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 104,
                      child: Text(
                        headers[i],
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: labelColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Expanded mencegah overflow ke kanan
                    Expanded(child: rows[index][i]),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // ── Desktop table ────────────────────────────────────────────────────────
  // Header dan body berada di dalam SATU SingleChildScrollView horizontal
  // sehingga selalu sinkron dan header tidak "terpisah" dari body.
  Widget _buildDesktopTable(
    bool isDark,
    Color borderColor,
    double screenWidth,
  ) {
    final headerBg = isDark ? const Color(0xFF1E1B3A) : const Color(0xFFF9F9FF);
    final headerTextColor = isDark
        ? AppTheme.darkTextSub
        : AppTheme.textSecondary;

    // screenWidth di sini sudah merupakan lebar actual widget (dari LayoutBuilder),
    // bukan lebar layar. Kurangi 2px untuk border kiri+kanan.
    final available = screenWidth - 2;
    final needsStretch = available > _minTotalWidth;

    final List<double> computedWidths;
    if (needsStretch) {
      final extra = available - _minTotalWidth;
      final perCol = extra / headers.length;
      computedWidths = _baseWidths.map((w) => w + perCol).toList();
    } else {
      computedWidths = _baseWidths;
    }

    final tableWidth = needsStretch ? available : _minTotalWidth;

    return Scrollbar(
      thumbVisibility:
          !needsStretch, // scrollbar hanya tampil kalau perlu scroll
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: needsStretch
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        child: SizedBox(
          width: tableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                color: headerBg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                child: Row(
                  children: List.generate(
                    headers.length,
                    (i) => SizedBox(
                      width: computedWidths[i],
                      child: Text(
                        headers[i],
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: headerTextColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Divider(height: 1, thickness: 1, color: borderColor),

              // Rows
              ...List.generate(rows.length, (index) {
                final isEven = index % 2 == 0;
                final rowBg = isDark
                    ? (isEven ? AppTheme.darkSurface : const Color(0xFF1A1730))
                    : (isEven ? Colors.white : const Color(0xFFFAFAFF));
                final isLast = index == rows.length - 1;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: rowBg,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(
                          rows[index].length,
                          (i) => SizedBox(
                            width: i < computedWidths.length
                                ? computedWidths[i]
                                : 130,
                            child: rows[index][i],
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(height: 1, thickness: 1, color: borderColor),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StatusBadge
// ─────────────────────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ActionButton
// ─────────────────────────────────────────────────────────────────────────────
class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 15),
        ),
      ),
    );
  }
}
