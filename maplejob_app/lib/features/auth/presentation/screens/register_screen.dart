import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/theme.dart';
import '../providers/auth_provider.dart';
import '../../../../app/services/analytics_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeToTerms = false;

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'You must agree to the Terms of Service and Privacy Policy.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      await AnalyticsService().logSignUp('email');
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).loginWithGoogle();
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1000 : 450,
            ),
            child: Card(
              elevation: 4,
              shadowColor: const Color.fromRGBO(0, 0, 0, 0.04),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(color: AppTheme.outlineVariantColor, width: 1.0),
              ),
              child: Row(
                children: [
                  // Left Side: Branding (Only Desktop)
                  if (isDesktop)
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 680,
                        color: AppTheme.primaryColor,
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MapleJob',
                              style: AppTheme.displayLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Text(
                              'The premium ecosystem for executive recruitment and real estate excellence. Elevate your career with authoritative tools and high-end networking.',
                              style: AppTheme.bodyLg.copyWith(
                                color: const Color.fromRGBO(255, 255, 255, 0.8),
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            // Small bullet points or feature boxes
                            Row(
                              children: [
                                const Icon(Icons.verified, color: AppTheme.secondaryColor, size: 24),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Text(
                                    'Verified Posts: Curated high-value opportunities.',
                                    style: AppTheme.titleMd.copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              children: [
                                const Icon(Icons.rocket_launch, color: AppTheme.secondaryColor, size: 24),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Text(
                                    'Fast Track: Direct pipelines to decision makers.',
                                    style: AppTheme.titleMd.copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Right Side: Form
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Mobile Logo
                            if (!isDesktop)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          borderRadius: BorderRadius.circular(6.0),
                                        ),
                                        child: const Icon(
                                          Icons.work,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        'MapleJob',
                                        style: AppTheme.titleMd.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            Text(
                              'Create Account',
                              style: AppTheme.headlineLgMobile.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Join the community of elite professionals',
                              style: AppTheme.bodyMd.copyWith(
                                color: AppTheme.outlineColor,
                              ),
                              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                            ),
                            const SizedBox(height: 24.0),

                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  color: AppTheme.rejectedBg,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: AppTheme.rejectedText),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: AppTheme.bodyMd.copyWith(color: AppTheme.rejectedText),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Full Name Field
                            Text(
                              'Full Name',
                              style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 6.0),
                            TextFormField(
                              controller: _fullNameController,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your full name.';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Johnathan Doe',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            // Email Field
                            Text(
                              'Email Address',
                              style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 6.0),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email.';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'j.doe@corporate.com',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            // Phone Number Field
                            Text(
                              'Phone Number',
                              style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 6.0),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your phone number.';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: '+1 (555) 000-0000',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            // Password Field
                            Text(
                              'Password',
                              style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 6.0),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a password.';
                                }
                                if (value.trim().length < 6) {
                                  return 'Password must be at least 6 characters.';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12.0),

                            // Terms checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  activeColor: AppTheme.secondaryColor,
                                  onChanged: (val) {
                                    setState(() {
                                      _agreeToTerms = val ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                                    child: RichText(
                                      text: TextSpan(
                                        style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                                        children: [
                                          const TextSpan(text: 'I agree to the '),
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: AppTheme.bodyMd.copyWith(
                                              color: AppTheme.secondaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: AppTheme.bodyMd.copyWith(
                                              color: AppTheme.secondaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(text: '.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16.0),

                            // Submit Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Create Account'),
                            ),

                            // Social signup divider
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Row(
                                children: [
                                  const Expanded(child: Divider(color: AppTheme.outlineVariantColor)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'Or register with',
                                      style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                                    ),
                                  ),
                                  const Expanded(child: Divider(color: AppTheme.outlineVariantColor)),
                                ],
                              ),
                            ),

                            // Google Sign-In button
                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : _handleGoogleLogin,
                              icon: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                                height: 20.0,
                              ),
                              label: const Text('Google'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.outlineVariantColor, width: 1.0),
                                foregroundColor: AppTheme.primaryColor,
                              ),
                            ),

                            const SizedBox(height: 24.0),

                            // Footer: redirect to login
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                                ),
                                GestureDetector(
                                  onTap: () => context.go('/login'),
                                  child: Text(
                                    ' Log In',
                                    style: AppTheme.bodyMd.copyWith(
                                      color: AppTheme.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
