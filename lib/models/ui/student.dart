// lib/models/ui/student.dart
import '../remote/student_response.dart';

class Student {
  final String id;
  final String nim;
  final String name;
  final String studyProgram;
  final String? phone;

  Student({
    required this.id,
    required this.nim,
    required this.name,
    required this.studyProgram,
    this.phone,
  });

  factory Student.fromRemote(StudentResponse remote) {
    return Student(
      id: remote.id,
      nim: remote.nim,
      name: remote.name,
      studyProgram: remote.studyProgram,
      phone: remote.phone,
    );
  }

  StudentResponse toRemote() {
    return StudentResponse(
      id: id,
      nim: nim,
      name: name,
      studyProgram: studyProgram,
      phone: phone,
    );
  }
}
