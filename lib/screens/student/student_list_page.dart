// lib/screens/student/student_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/student/student_list_bloc.dart';
import '../../models/ui/student.dart';
import '../../repositories/student_repository.dart';
import '../../utils/app_theme.dart';
import '../../utils/remote_helper.dart';
import '../../widgets/data_table_card.dart';
import 'student_detail_page.dart';

class StudentListPage extends StatefulWidget {
  final StudentListBloc? studentBloc;
  const StudentListPage({super.key, required this.studentBloc});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  String _searchQuery = '';
  late final StudentListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.studentBloc ??
        StudentListBloc(studentRepository: StudentRepository(RemoteHelper.getDio()))
          ..add(LoadStudentListEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? AppTheme.darkBg : AppTheme.background;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor  = isDark ? AppTheme.darkTextSub : AppTheme.textSecondary;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text('Data Mahasiswa',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: isDark ? AppTheme.darkSurface : AppTheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Cari mahasiswa...',
                        prefixIcon: Icon(Icons.search_rounded, size: 18),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        constraints: BoxConstraints(maxHeight: 42),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _onCreateClick(context),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<StudentListBloc, StudentListState>(
                builder: (context, state) {
                  final isLoading = state is StudentListLoading;
                  final students = state is StudentListLoaded
                      ? state.students.where((s) =>
                          s.name.toLowerCase().contains(_searchQuery) ||
                          s.nim.toLowerCase().contains(_searchQuery) ||
                          s.studyProgram.toLowerCase().contains(_searchQuery)
                        ).toList()
                      : <Student>[];

                  return DataTableCard(
                    isLoading: isLoading,
                    emptyMessage: 'Belum ada data mahasiswa',
                    emptyIcon: Icons.people_rounded,
                    headers: const ['ID', 'NIM', 'NAMA', 'PROGRAM STUDI', 'NO. HP', 'AKSI'],
                    rows: students.map((s) => [
                      Text(s.id, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: subColor)),
                      Text(s.nim, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                      Row(children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.surfaceVariant,
                          child: Text(s.name[0].toUpperCase(),
                            style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(s.name, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w500, color: textColor))),
                      ]),
                      Text(s.studyProgram, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: subColor)),
                      Text(s.phone ?? '-', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: subColor)),
                      Row(children: [
                        ActionButton(icon: Icons.edit_rounded, color: AppTheme.primary, tooltip: 'Edit', onTap: () => _onEditClick(context, s)),
                        const SizedBox(width: 6),
                        ActionButton(icon: Icons.delete_rounded, color: AppTheme.error, tooltip: 'Hapus', onTap: () => _onEditClick(context, s)),
                      ]),
                    ]).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCreateClick(BuildContext context) async {
    var result = await Navigator.push(context,
      MaterialPageRoute(builder: (_) => const StudentDetailPage(student: null)));
    if (result is StudentCreatedResult) {
      _bloc.add(AddNewStudentEvent(newStudent: result.student));
    }
  }

  void _onEditClick(BuildContext context, Student s) async {
    var result = await Navigator.push(context,
      MaterialPageRoute(builder: (_) => StudentDetailPage(student: s)));
    if (result is StudentUpdatedResult) {
      _bloc.add(UpdateStudentEvent(updatedStudent: result.student));
    } else if (result is StudentDeletedResult) {
      _bloc.add(DeleteStudentEvent(deletedStudent: result.student));
    }
  }
}