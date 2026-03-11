// lib/screens/student/student_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/student/student_list_bloc.dart';
import '../../models/ui/student.dart';
import '../../utils/app_theme.dart';
import 'student_detail_page.dart';

class StudentListPage extends StatefulWidget {
  final StudentListBloc studentBloc;
  const StudentListPage({super.key, required this.studentBloc});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.studentBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.navyDark,
          title: const Text("Data Mahasiswa", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => widget.studentBloc.add(LoadStudentListEvent()),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primary,
          onPressed: () => _onCreateClick(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: BlocBuilder<StudentListBloc, StudentListState>(
            builder: (context, state) {
              if (state is StudentListLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is StudentListLoaded) {
                if (state.students.isEmpty) {
                  return const Center(child: Text("Belum ada data mahasiswa"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  primary: false,
                  itemCount: state.students.length,
                  itemBuilder: (context, index) {
                    final s = state.students[index];
                    return GestureDetector(
                      onTap: () => _onCardClicked(s),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0DFFF)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.surfaceVariant,
                              child: Text(
                                s.name.isNotEmpty ? s.name[0].toUpperCase() : "?",
                                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(s.nim, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text(s.studyProgram, style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (state is StudentListError) {
                return Center(child: Text("Error: ${state.message}"));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  void _onCardClicked(Student student) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudentDetailPage(student: student)),
    );
    if (result is StudentUpdatedResult) {
      widget.studentBloc.add(UpdateStudentEvent(updatedStudent: result.student));
    } else if (result is StudentDeletedResult) {
      widget.studentBloc.add(DeleteStudentEvent(deletedStudent: result.student));
    }
  }

  void _onCreateClick(BuildContext context) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentDetailPage(student: null)),
    );
    if (result is StudentCreatedResult) {
      widget.studentBloc.add(AddNewStudentEvent(newStudent: result.student));
    }
  }
}