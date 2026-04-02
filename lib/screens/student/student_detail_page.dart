// lib/screens/student/student_detail_page.dart
import 'package:flutter/material.dart';
import '../../models/ui/student.dart';
import '../../repositories/student_repository.dart';
import '../../utils/remote_helper.dart';
import '../../utils/app_theme.dart';

// ── Bottom sheet launcher ──────────────────────────────────────────────────
Future<dynamic> showStudentForm(BuildContext context, {Student? student}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StudentFormSheet(student: student),
  );
}

// ── Wrapper page (dipakai routes, tidak berubah) ───────────────────────────
class StudentDetailPage extends StatelessWidget {
  final Student? student;
  const StudentDetailPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    // Langsung tampil sebagai bottom sheet di atas halaman kosong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showStudentForm(context, student: student).then((result) {
        if (context.mounted) Navigator.pop(context, result);
      });
    });
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}

// ── Form bottom sheet ──────────────────────────────────────────────────────
class _StudentFormSheet extends StatefulWidget {
  final Student? student;
  const _StudentFormSheet({this.student});

  @override
  State<_StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends State<_StudentFormSheet> {
  bool _isLoading   = false;
  bool _isLoadingId = false;

  final _idController      = TextEditingController();
  final _nimController     = TextEditingController();
  final _nameController    = TextEditingController();
  final _programController = TextEditingController();
  final _phoneController   = TextEditingController();

  final StudentRepository _repository = StudentRepository(RemoteHelper.getDio());

  bool get _isCreate => widget.student == null;

  @override
  void initState() {
    super.initState();
    if (!_isCreate) {
      _idController.text      = widget.student!.id;
      _nimController.text     = widget.student!.nim;
      _nameController.text    = widget.student!.name;
      _programController.text = widget.student!.studyProgram;
      _phoneController.text   = widget.student!.phone ?? '';
    } else {
      _generateNextId();
    }
  }

  Future<void> _generateNextId() async {
    setState(() => _isLoadingId = true);
    try {
      final res  = await RemoteHelper.getDio().get('api/students');
      final list = (res.data['data'] as List<dynamic>?) ?? [];
      const prefix = 'STD';
      int max = 0;
      for (final s in list) {
        final id = (s['id'] ?? '') as String;
        if (id.startsWith(prefix)) {
          final num = int.tryParse(id.substring(prefix.length)) ?? 0;
          if (num > max) max = num;
        }
      }
      final nextId = '$prefix${(max + 1).toString().padLeft(3, '0')}';
      if (mounted) setState(() { _idController.text = nextId; _isLoadingId = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingId = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final sheetBg   = isDark ? AppTheme.darkSurface : Colors.white;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(16, 0, 16,
        MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBorder : Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
            )),

            // Title
            Text(_isCreate ? 'Tambah Mahasiswa' : 'Edit Mahasiswa',
              style: TextStyle(fontFamily: AppTheme.fontFamily,
                fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 16),

            // ID (read-only)
            if (_isCreate) ...[
              _label('ID Mahasiswa', subColor),
              _isLoadingId ? _loadingBox() : _readOnlyBox(_idController.text, isDark),
              const SizedBox(height: 14),
            ],

            _label('NIM', subColor),
            _inputField(controller: _nimController, hint: 'Masukkan NIM',
              isDark: isDark, textColor: textColor),
            const SizedBox(height: 14),

            _label('Nama Lengkap', subColor),
            _inputField(controller: _nameController, hint: 'Nama lengkap',
              isDark: isDark, textColor: textColor),
            const SizedBox(height: 14),

            _label('Program Studi', subColor),
            _inputField(controller: _programController,
              hint: 'Contoh: Teknik Informatika',
              isDark: isDark, textColor: textColor),
            const SizedBox(height: 14),

            _label('Nomor HP (opsional)', subColor),
            _inputField(controller: _phoneController, hint: '08xxxxxxxxxx',
              isDark: isDark, textColor: textColor,
              keyboardType: TextInputType.phone),
            const SizedBox(height: 20),

            // Tombol
            Row(children: [
              if (!_isCreate) ...[
                Expanded(child: OutlinedButton(
                  onPressed: _isLoading ? null : _onDeleteClick,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Hapus',
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
                )),
                const SizedBox(width: 12),
              ],
              Expanded(child: ElevatedButton(
                onPressed: _isLoading ? null : _onSaveClick,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isCreate ? 'Tambah Mahasiswa' : 'Simpan Perubahan',
                      style: const TextStyle(fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w600, fontSize: 14)),
              )),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, Color color) => Padding(
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

  Widget _loadingBox() => Container(
    height: 48,
    decoration: BoxDecoration(
      color: const Color(0xFFF0F0F8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE8E8F0)),
    ),
    child: const Center(child: SizedBox(width: 18, height: 18,
      child: CircularProgressIndicator(strokeWidth: 2))),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required Color textColor,
    TextInputType keyboardType = TextInputType.text,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? AppTheme.darkSurfaceVar : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
    ),
  );

  void _onSaveClick() async {
    if (_nimController.text.isEmpty || _nameController.text.isEmpty ||
        _programController.text.isEmpty) {
      _showMessage('NIM, nama, dan program studi wajib diisi!'); return;
    }
    setState(() => _isLoading = true);
    final data = {
      'id': _idController.text,
      'nim': _nimController.text,
      'name': _nameController.text,
      'studyProgram': _programController.text,
      'phone': _phoneController.text.isNotEmpty ? _phoneController.text : null,
    };
    if (_isCreate) {
      final result = await _repository.createStudent(data);
      setState(() => _isLoading = false);
      if (result.isSuccess && result.data != null) {
        if (!mounted) return;
        Navigator.pop(context, StudentCreatedResult(student: Student.fromRemote(result.data!)));
      } else { _showMessage(result.message); }
    } else {
      final result = await _repository.updateStudent(widget.student!.id, data);
      setState(() => _isLoading = false);
      if (result.isSuccess && result.data != null) {
        if (!mounted) return;
        Navigator.pop(context, StudentUpdatedResult(student: Student.fromRemote(result.data!)));
      } else { _showMessage(result.message); }
    }
  }

  void _onDeleteClick() async {
    setState(() => _isLoading = true);
    final result = await _repository.deleteStudent(widget.student!.id);
    setState(() => _isLoading = false);
    if (result.isSuccess) {
      if (!mounted) return;
      Navigator.pop(context, StudentDeletedResult(student: widget.student!));
    } else { _showMessage(result.message); }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontFamily: AppTheme.fontFamily)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

class StudentCreatedResult  { final Student student; StudentCreatedResult({required this.student}); }
class StudentUpdatedResult  { final Student student; StudentUpdatedResult({required this.student}); }
class StudentDeletedResult  { final Student student; StudentDeletedResult({required this.student}); }