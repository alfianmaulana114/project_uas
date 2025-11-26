import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

/// Login Screen
/// Screen untuk melakukan sign in user
/// Mengikuti konsep Single Responsibility Principle
class LoginScreen extends StatefulWidget {
  /// Constructor untuk LoginScreen
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Form key untuk validasi form
  final _formKey = GlobalKey<FormState>();

  /// Controller untuk email field
  final _emailController = TextEditingController();

  /// Controller untuk password field
  final _passwordController = TextEditingController();

  /// Apakah password visible atau tidak
  bool _isPasswordVisible = false;

  /// Method untuk handle sign in
  Future<void> _handleSignIn() async {
    /// Validasi form terlebih dahulu
    if (_formKey.currentState!.validate()) {
      /// Get AuthProvider dari context
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      /// Call sign in method
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      /// Jika berhasil, navigate ke home/dashboard
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else if (mounted) {
        /// Jika gagal, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Gagal melakukan sign in'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Method untuk dispose resources
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Build method untuk membuat widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                /// Logo aplikasi
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 140,
                    fit: BoxFit.contain,
                    semanticLabel: 'Logo SosialBreak',
                  ),
                ),

                const SizedBox(height: 24),

                /// Title
                Text(
                  'Selamat Datang',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                /// Subtitle
                Text(
                  'Masuk ke akun SosialBreak Anda',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                /// Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Masukkan email Anda',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Masukkan password Anda',
                  icon: Icons.lock_outlined,
                  isPassword: !_isPasswordVisible,
                  isRequired: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 32),

                /// Sign in button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      text: 'Masuk',
                      onPressed: authProvider.isLoading ? null : _handleSignIn,
                      isLoading: authProvider.isLoading,
                      icon: Icons.login,
                    );
                  },
                ),

                const SizedBox(height: 24),

                /// Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: Text(
                        'Daftar Sekarang',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

