import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/neon_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final horizontalPadding = isSmallScreen ? 24.0 : 32.0;
    final maxWidth = 420.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF020712),
              Color(0xFF101727),
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Radial gradient overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.10,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.5, 0.3),
                      radius: 1.6,
                      colors: [
                        const Color(0x4C06B6D4),
                        Colors.black.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    NavigationHelper.navigateToHome(context);
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: isSmallScreen ? 40 : 60),
                              // Logo
                              Center(
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: ShapeDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF00D2F2),
                                        Color(0xFF0092B8),
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: const Color(0x7F06B6D4),
                                        blurRadius: 30,
                                        offset: Offset.zero,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.security,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 24 : 32),
                              // Welcome Back Title
                              const Text(
                                'Welcome Back',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.11,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              // Subtitle
                              const Text(
                                'Sign in to continue',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF99A1AE),
                                  fontSize: 16,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 32 : 48),
                              // Glass container with form
                              GlassContainer(
                                padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Email Field
                                    CustomTextField(
                                      label: 'Username',
                                      hintText: 'username',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      // validator: (value) {
                                      //   if (value == null || value.isEmpty) {
                                      //     return 'Please enter your email';
                                      //   }
                                      //   if (!value.contains('@') || !value.contains('.')) {
                                      //     return 'Please enter a valid email';
                                      //   }
                                      //   return null;
                                      // },
                                    ),
                                    SizedBox(height: isSmallScreen ? 16 : 24),
                                    // Password Field
                                    CustomTextField(
                                      label: 'Password',
                                      hintText: 'Enter your password',
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: const Color(0xFF697282),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: isSmallScreen ? 12 : 16),
                                    // Forgot Password Link
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          // TODO: Navigate to forgot password screen
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: Color(0xFF00D2F2),
                                            fontSize: 14,
                                            fontFamily: 'Arimo',
                                            fontWeight: FontWeight.w400,
                                            height: 1.43,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 20 : 24),
                                    // Login Button
                                    NeonButton(
                                      text: 'Login',
                                      isLoading: state is AuthLoading,
                                      gradientColors: const [
                                        Color(0xFFF0B000),
                                        Color(0xFFD08700),
                                      ],
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<AuthCubit>().login(
                                                _emailController.text.trim(),
                                                _passwordController.text,
                                              );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 24 : 32),
                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      color: Color(0xFF99A1AE),
                                      fontSize: 16,
                                      fontFamily: 'Arimo',
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  TextButton(
                                    onPressed: () {
                                      NavigationHelper.navigateToRegister(context);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Create one',
                                      style: TextStyle(
                                        color: Color(0xFF00D2F2),
                                        fontSize: 16,
                                        fontFamily: 'Arimo',
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 40 : 60),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
