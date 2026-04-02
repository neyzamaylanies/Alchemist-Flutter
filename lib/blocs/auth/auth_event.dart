abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  LoginSubmitted({required this.email, required this.password});
}

class GuestLoginRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}