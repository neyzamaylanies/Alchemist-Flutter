// lib/blocs/student/student_list_event.dart
part of 'student_list_bloc.dart';

@immutable
sealed class StudentListEvent {}

class LoadStudentListEvent extends StudentListEvent {}

class AddNewStudentEvent extends StudentListEvent {
  final Student newStudent;
  AddNewStudentEvent({required this.newStudent});
}

class UpdateStudentEvent extends StudentListEvent {
  final Student updatedStudent;
  UpdateStudentEvent({required this.updatedStudent});
}

class DeleteStudentEvent extends StudentListEvent {
  final Student deletedStudent;
  DeleteStudentEvent({required this.deletedStudent});
}
