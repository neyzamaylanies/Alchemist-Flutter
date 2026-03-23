// lib/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../utils/app_theme.dart';
import '../../utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
    _navigateToMain();
  }

  void _navigateToMain() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      Navigator.pushReplacementNamed(context, Routes.main);
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.sidebarBg,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.2,
                colors: [
                  AppTheme.primary.withValues(alpha: 0.15),
                  AppTheme.sidebarBg,
                ],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.purpleDeep.withValues(alpha: 0.07),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnim.value),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3730A3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/logo/LogoAlchemist.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Alchemist',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sistem Manajemen Inventory Laboratorium',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.5),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 60),
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppTheme.primary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
