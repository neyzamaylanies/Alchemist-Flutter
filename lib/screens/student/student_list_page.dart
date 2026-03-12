// lib/screens/student/student_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/student/student_list_bloc.dart';
import '../../models/ui/student.dart';
import '../../utils/app_theme.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/data_table_card.dart';
import 'student_detail_page.dart';

class StudentListPage extends StatefulWidget {
  final StudentListBloc studentBloc;
  const StudentListPage({super.key, required this.studentBloc});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.studentBloc,
      child: PageScaffold(
        title: 'Data Mahasiswa',
        searchHint: 'Cari mahasiswa...',
        onSearch: (q) => setState(() => _searchQuery = q.toLowerCase()),
        actionLabel: '+ Tambah Mahasiswa',
        onAction: () => _onCreateClick(context),
        body: BlocBuilder<StudentListBloc, StudentListState>(
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
                Text(s.id, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                Text(s.nim, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600)),
                Row(children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppTheme.surfaceVariant,
                    child: Text(s.name[0].toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s.name, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w500))),
                ]),
                Text(s.studyProgram, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                Text(s.phone ?? '-', style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                Row(children: [
                  ActionButton(icon: Icons.edit_rounded, color: AppTheme.primary, tooltip: 'Edit', onTap: () => _onEditClick(s)),
                  const SizedBox(width: 6),
                  ActionButton(icon: Icons.delete_rounded, color: AppTheme.error, tooltip: 'Hapus', onTap: () => _onEditClick(s)),
                ]),
              ]).toList(),
            );
          },
        ),
      ),
    );
  }

  void _onCreateClick(BuildContext context) async {
    var result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentDetailPage(student: null)));
    if (result is StudentCreatedResult) {
      widget.studentBloc.add(AddNewStudentEvent(newStudent: result.student));
    }
  }

  void _onEditClick(Student s) async {
    var result = await Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailPage(student: s)));
    if (result is StudentUpdatedResult) {
      widget.studentBloc.add(UpdateStudentEvent(updatedStudent: result.student));
    } else if (result is StudentDeletedResult) {
      widget.studentBloc.add(DeleteStudentEvent(deletedStudent: result.student));
    }
  }
}