import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/theme.dart';
import '../providers/auth_provider.dart';
import '../../../../app/services/analytics_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Phone OTP specific state
  bool _isPhoneMode = false;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;
  bool _otpSent = false;

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      await AnalyticsService().logLogin('email');
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
      await AnalyticsService().logLogin('google');
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

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid phone number.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await ref.read(authControllerProvider.notifier).requestPhoneOtp(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
          _isLoading = false;
          _errorMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully.')),
        );
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.replaceAll('Exception: ', '');
        });
      },
    );
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpController.text.trim();
    if (code.isEmpty || _verificationId == null) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit OTP.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).loginWithPhoneOtp(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await AnalyticsService().logLogin('phone_otp');
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

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in your Email Address to trigger password reset.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to your email.')),
      );
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
                  // Branding side (Only on desktop width)
                  if (isDesktop)
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 600,
                        color: AppTheme.primaryColor,
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Icon(
                                    Icons.work,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Text(
                                  'MapleJob',
                                  style: AppTheme.titleLg.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unlock your professional potential.',
                                  style: AppTheme.headlineLg.copyWith(
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'The premium recruitment ecosystem for high-end corporate career growth and seamless hiring experiences.',
                                  style: AppTheme.bodyLg.copyWith(
                                    color: const Color.fromRGBO(255, 255, 255, 0.8),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '"The most efficient way we\'ve ever scaled our senior management team." — HR Director, Global Tech',
                              style: AppTheme.bodyMd.copyWith(
                                color: const Color.fromRGBO(255, 255, 255, 0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Login Form side
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
                              'Welcome back',
                              style: AppTheme.headlineLgMobile.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              _isPhoneMode
                                  ? 'Enter your phone number to sign in with OTP'
                                  : 'Enter your credentials to access your dashboard',
                              style: AppTheme.bodyMd.copyWith(
                                color: AppTheme.outlineColor,
                              ),
                              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                            ),
                            const SizedBox(height: 32.0),

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

                            // Standard Email Password View
                            if (!_isPhoneMode) ...[
                              // Email Field
                              Text(
                                'Email Address',
                                style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor),
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email address.';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                    return 'Please enter a valid email address.';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'name@company.com',
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                              ),
                              const SizedBox(height: 20.0),

                              // Password Field
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Password',
                                    style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor),
                                  ),
                                  GestureDetector(
                                    onTap: _handleForgotPassword,
                                    child: Text(
                                      'Forgot Password?',
                                      style: AppTheme.labelLg.copyWith(
                                        color: AppTheme.secondaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your password.';
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
                            ],

                            // Phone OTP View
                            if (_isPhoneMode) ...[
                              Text(
                                'Phone Number',
                                style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        hintText: '+1 (555) 000-0000',
                                        prefixIcon: Icon(Icons.phone_outlined),
                                      ),
                                      enabled: !_otpSent,
                                    ),
                                  ),
                                  if (!_otpSent) ...[
                                    const SizedBox(width: 8.0),
                                    ElevatedButton(
                                      onPressed: _isLoading ? null : _handleSendOtp,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                      ),
                                      child: const Text('Send OTP'),
                                    ),
                                  ]
                                ],
                              ),
                              if (_otpSent) ...[
                                const SizedBox(height: 20.0),
                                Text(
                                  'Enter 6-digit OTP',
                                  style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor),
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '123456',
                                    prefixIcon: Icon(Icons.lock_open_outlined),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _otpSent = false;
                                          _verificationId = null;
                                          _otpController.clear();
                                        });
                                      },
                                      child: const Text('Change Phone Number'),
                                    ),
                                  ],
                                ),
                              ],
                            ],

                            const SizedBox(height: 28.0),

                            // Submit Login Button
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : (_isPhoneMode
                                      ? (_otpSent ? _handleVerifyOtp : _handleSendOtp)
                                      : _handleEmailLogin),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(_isPhoneMode
                                      ? (_otpSent ? 'Verify & Login' : 'Send Verification SMS')
                                      : 'Log In'),
                            ),

                            const SizedBox(height: 16.0),

                            // Toggle Phone/Email authentication method
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isPhoneMode = !_isPhoneMode;
                                  _errorMessage = null;
                                  _otpSent = false;
                                  _verificationId = null;
                                });
                              },
                              child: Text(_isPhoneMode ? 'Use Email & Password' : 'Sign in with Phone OTP'),
                            ),

                            // Divider
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Row(
                                children: [
                                  const Expanded(child: Divider(color: AppTheme.outlineVariantColor)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'Or login with',
                                      style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                                    ),
                                  ),
                                  const Expanded(child: Divider(color: AppTheme.outlineVariantColor)),
                                ],
                              ),
                            ),

                            // Google Sign-In
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

                            const SizedBox(height: 28.0),

                            // Footer link to Signup
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                                ),
                                GestureDetector(
                                  onTap: () => context.go('/register'),
                                  child: Text(
                                    ' Register',
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
