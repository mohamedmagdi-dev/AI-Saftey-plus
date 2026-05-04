// EXAMPLE: Refactored Login Screen using new widgets and BLoC
// This demonstrates the refactoring pattern for all screens

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/neon_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../cubit/auth_cubit.dart';

class LoginScreenRefactored extends StatefulWidget {
  const LoginScreenRefactored({super.key});

  @override
  State<LoginScreenRefactored> createState() => _LoginScreenRefactoredState();
}

class _LoginScreenRefactoredState extends State<LoginScreenRefactored> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                NavigationHelper.navigateToHome(context);
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 80),
                      // Title
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue',
                        style: TextStyle(
                          color: Color(0xFF99A1AE),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // Email Field
                      CustomTextField(
                        label: 'Email',
                        hintText: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        obscureText: true,
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
                      const SizedBox(height: 24),
                      // Login Button
                      NeonButton(
                        text: 'Sign In',
                        isLoading: state is AuthLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Register Link
                      TextButton(
                        onPressed: () {
                          NavigationHelper.navigateToRegister(context);
                        },
                        child: const Text(
                          "Don't have an account? Register",
                          style: TextStyle(
                            color: Color(0xFF00D2F2),
                            fontSize: 14,
                            fontFamily: 'Arimo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
