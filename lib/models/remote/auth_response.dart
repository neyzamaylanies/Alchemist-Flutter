class AuthResponse {
  final String token;
  final String id;
  final String name;
  final String email;
  final String role;

  AuthResponse({
    required this.token,
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthResponse(
      token: data['token'],
      id: data['id'],
      name: data['name'],
      email: data['email'],
      role: data['role'],
    );
  }
}
