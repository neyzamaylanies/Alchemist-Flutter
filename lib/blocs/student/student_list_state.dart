// lib/blocs/student/student_list_state.dart
part of 'student_list_bloc.dart';

@immutable
sealed class StudentListState {}

final class StudentListInitial extends StudentListState {}

final class StudentListLoading extends StudentListState {}

final class StudentListLoaded extends StudentListState {
  final List<Student> students;
  StudentListLoaded({required this.students});
}

final class StudentListError extends StudentListState {
  final String message;
  StudentListError({required this.message});
}
