import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

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
        return 90;
      case 'AKSI':
        return 80;
      case 'JUMLAH':
        return 70;
      case 'PETUGAS':
        return 90;
      case 'PEMINJAM':
        return 100;
      case 'TANGGAL':
        return 110;
      default:
        return 130;
    }
  }

  List<double> get _widths {
    if (columnWidths != null && columnWidths!.length == headers.length) {
      return columnWidths!;
    }
    return headers.map(_defaultWidth).toList();
  }

  double get _totalWidth => _widths.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    final cardColor = isDark ? AppTheme.darkSurface : AppTheme.surface;
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);
    final headerBg = isDark ? const Color(0xFF1E1B3A) : const Color(0xFFF9F9FF);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // HEADER (desktop only)
          if (!isMobile)
            Container(
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _totalWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: List.generate(
                        headers.length,
                        (i) => SizedBox(
                          width: _widths[i],
                          child: Text(
                            headers[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppTheme.darkTextSub
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // BODY
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(emptyIcon, size: 48),
                  const SizedBox(height: 12),
                  Text(emptyMessage),
                ],
              ),
            )
          else
            isMobile
                ? _buildMobileList(context)
                : _buildDesktopTable(context, borderColor, isDark),
        ],
      ),
    );
  }

  // ================= MOBILE =================
  Widget _buildMobileList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1730) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(headers.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        headers[i],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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

  // ================= DESKTOP =================
  Widget _buildDesktopTable(
    BuildContext context,
    Color borderColor,
    bool isDark,
  ) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _totalWidth,
          child: Column(
            children: List.generate(rows.length, (index) {
              final isEven = index % 2 == 0;
              final rowBg = isDark
                  ? (isEven ? AppTheme.darkSurface : const Color(0xFF1A1730))
                  : (isEven ? Colors.white : const Color(0xFFFAFAFF));

              return Container(
                decoration: BoxDecoration(
                  color: rowBg,
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: List.generate(
                      rows[index].length,
                      (i) => SizedBox(
                        width: i < _widths.length ? _widths[i] : 130,
                        child: rows[index][i],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
} // ✅ INI PENUTUP DataTableCard

// ================= BADGE =================
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ================= BUTTON =================
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
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}
