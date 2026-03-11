// lib/blocs/student/student_list_bloc.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/ui/student.dart';
import '../../repositories/student_repository.dart';

part 'student_list_event.dart';
part 'student_list_state.dart';

class StudentListBloc extends Bloc<StudentListEvent, StudentListState> {
  final StudentRepository studentRepository;
  final List<Student> _currentList = [];

  StudentListBloc({required this.studentRepository})
      : super(StudentListInitial()) {
    on<LoadStudentListEvent>((event, emit) async {
      emit(StudentListLoading());
      var result = await studentRepository.getStudentList();
      if (result.isSuccess) {
        var mapped =
            result.data?.map((e) => Student.fromRemote(e)).toList() ?? [];
        _currentList.clear();
        _currentList.addAll(mapped);
        emit(StudentListLoaded(students: List.from(_currentList)));
      } else {
        emit(StudentListError(message: result.message));
      }
    });

    on<AddNewStudentEvent>((event, emit) {
      _currentList.add(event.newStudent);
      emit(StudentListLoaded(students: List.from(_currentList)));
    });

    on<UpdateStudentEvent>((event, emit) {
      var index = _currentList.indexWhere((s) => s.id == event.updatedStudent.id);
      if (index != -1) _currentList[index] = event.updatedStudent;
      emit(StudentListLoaded(students: List.from(_currentList)));
    });

    on<DeleteStudentEvent>((event, emit) {
      _currentList.removeWhere((s) => s.id == event.deletedStudent.id);
      emit(StudentListLoaded(students: List.from(_currentList)));
    });
  }
}
