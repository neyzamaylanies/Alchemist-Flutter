// lib/models/remote/user_response.dart
class UserResponse {
  final String id;
  final String name;
  final String email;
  final String role;

  UserResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      role: json["role"] ?? "PETUGAS",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "role": role,
    };
  }
}
