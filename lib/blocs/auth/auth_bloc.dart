import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/remote_helper.dart';
import '../../utils/session_helper.dart';
import '../../utils/shared_preference_helper.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckAuth);
    on<LoginSubmitted>(_onLogin);
    on<GuestLoginRequested>(_onGuestLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheckAuth(AuthCheckRequested event, Emitter emit) async {
    final token = await SharedPreferenceHelper.getToken();
    if (token != null) {
      final info = await SharedPreferenceHelper.getUserInfo();
      SessionHelper.setSession(
        id: info['id'] ?? '',
        name: info['name'] ?? '',
        email: info['email'] ?? '',
        role: info['role'] ?? '',
      );
      emit(AuthAuthenticated(name: info['name'] ?? '', role: info['role'] ?? ''));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginSubmitted event, Emitter emit) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.login(event.email, event.password);
      await SharedPreferenceHelper.saveToken(result.token);
      await SharedPreferenceHelper.saveUserInfo(
        id: result.id,
        name: result.name,
        email: result.email,
        role: result.role,
      );
      SessionHelper.setSession(
        id: result.id,
        name: result.name,
        email: result.email,
        role: result.role,
      );
      emit(AuthAuthenticated(name: result.name, role: result.role));
    } catch (e) {
      emit(AuthError('Email atau password salah'));
    }
  }

  /// Masuk tanpa login — set session sebagai tamu
  Future<void> _onGuestLogin(GuestLoginRequested event, Emitter emit) async {
    SessionHelper.setSession(
      id: 'GUEST',
      name: 'Tamu',
      email: 'tamu@alchemist.app',
      role: 'GUEST',
    );
    // Tidak simpan ke SharedPreferences supaya saat restart tetap minta login
    emit(AuthAuthenticated(name: 'Tamu', role: 'GUEST'));
  }

  Future<void> _onLogout(LogoutRequested event, Emitter emit) async {
    await _authRepository.logout();
    await SharedPreferenceHelper.clearAll();
    SessionHelper.clearSession();
    RemoteHelper.resetDio();
    emit(AuthUnauthenticated());
  }
}