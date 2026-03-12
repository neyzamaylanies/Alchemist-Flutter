// lib/widgets/page_scaffold.dart
// Reusable scaffold untuk semua list page dengan search + action button
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PageScaffold extends StatelessWidget {
  final String title;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top action bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            children: [
              if (searchHint != null && onSearch != null)
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      onChanged: onSearch,
                      style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: searchHint,
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: AppTheme.surface,
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),
              if (extraActions != null) ...extraActions!,
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(actionLabel!, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: body),
      ],
    );
  }
}