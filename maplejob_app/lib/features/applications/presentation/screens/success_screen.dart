import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/theme.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 4,
              shadowColor: const Color.fromRGBO(0, 0, 0, 0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppTheme.outlineVariantColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppTheme.appliedBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppTheme.appliedText,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    Text(
                      'Application Submitted!',
                      style: AppTheme.headlineLgMobile.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Your professional profile and resume have been successfully transmitted to the MapleHub Realty HR team. We will review your application shortly.',
                      style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48.0),
                    ElevatedButton(
                      onPressed: () => context.go('/applications'),
                      child: const Text('Track Application'),
                    ),
                    const SizedBox(height: 12.0),
                    OutlinedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Explore Other Jobs'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
