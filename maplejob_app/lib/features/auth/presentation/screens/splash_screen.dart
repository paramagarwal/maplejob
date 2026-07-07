import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show splash for at least 2.5 seconds for branding presence
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      },
      error: (err, _) => context.go('/login'),
      loading: () {
        // Fallback if auth state is still loading
        context.go('/login');
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          // Background Glow effect
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0x265095FE), // 15% opacity secondary container blue
                    AppTheme.primaryColor,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MapleJob',
                    style: AppTheme.displayLg.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'BY MAPLEHUB REALTY',
                    style: AppTheme.labelLg.copyWith(
                      color: Colors.white.withAlpha(150),
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48.0),
                  // Loading Bar
                  Container(
                    width: 140.0,
                    height: 2.0,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                    child: const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'INITIALIZING PLATFORM',
                    style: AppTheme.labelSm.copyWith(
                      color: Colors.white.withAlpha(80),
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating Footer
          Positioned(
            bottom: 32.0,
            left: 24.0,
            right: 24.0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EST. 2026',
                    style: AppTheme.labelSm.copyWith(
                      color: Colors.white.withAlpha(50),
                    ),
                  ),
                  Container(
                    width: 60.0,
                    height: 1.0,
                    color: Colors.white.withAlpha(30),
                  ),
                  Text(
                    'PREMIUM RECRUITMENT ECOSYSTEM',
                    style: AppTheme.labelSm.copyWith(
                      color: Colors.white.withAlpha(50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
