// lib/models/remote/student_response.dart
class StudentResponse {
  final String id;
  final String nim;
  final String name;
  final String studyProgram;
  final String? phone;

  StudentResponse({
    required this.id,
    required this.nim,
    required this.name,
    required this.studyProgram,
    this.phone,
  });

  factory StudentResponse.fromJson(Map<String, dynamic> json) {
    return StudentResponse(
      id: json["id"] ?? "",
      nim: json["nim"] ?? "",
      name: json["name"] ?? "",
      studyProgram: json["studyProgram"] ?? "",
      phone: json["phone"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nim": nim,
      "name": name,
      "studyProgram": studyProgram,
      "phone": phone,
    };
  }
}
