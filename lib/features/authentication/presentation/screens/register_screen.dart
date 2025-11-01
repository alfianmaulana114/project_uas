import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

/// Register Screen
/// Screen untuk melakukan sign up user baru
/// Mengikuti konsep Single Responsibility Principle
class RegisterScreen extends StatefulWidget {
  /// Constructor untuk RegisterScreen
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// Form key untuk validasi form
  final _formKey = GlobalKey<FormState>();

  /// Controller untuk email field
  final _emailController = TextEditingController();

  /// Controller untuk password field
  final _passwordController = TextEditingController();

  /// Controller untuk confirm password field
  final _confirmPasswordController = TextEditingController();

  /// Controller untuk full name field
  final _fullNameController = TextEditingController();

  /// Controller untuk username field
  final _usernameController = TextEditingController();

  /// Apakah password visible atau tidak
  bool _isPasswordVisible = false;

  /// Apakah confirm password visible atau tidak
  bool _isConfirmPasswordVisible = false;

  /// Method untuk handle sign up
  Future<void> _handleSignUp() async {
    /// Validasi form terlebih dahulu
    if (_formKey.currentState!.validate()) {
      /// Validasi password match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password dan konfirmasi password tidak sama'),
          ),
        );
        return;
      }

      /// Get AuthProvider dari context
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      /// Call sign up method
      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim().isEmpty
            ? null
            : _fullNameController.text.trim(),
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
      );

      /// Jika berhasil, navigate ke home/dashboard
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else if (mounted) {
        /// Jika gagal, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Gagal melakukan sign up'),
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
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  /// Build method untuk membuat widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Title
                Text(
                  'Buat Akun Baru',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                /// Subtitle
                Text(
                  'Daftar sekarang dan mulai kelola waktu bermain sosmed Anda',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                /// Full name field (opsional)
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap Anda (opsional)',
                  icon: Icons.person_outlined,
                  keyboardType: TextInputType.name,
                ),

                const SizedBox(height: 20),

                /// Username field (opsional)
                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Masukkan username Anda (opsional)',
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.text,
                ),

                const SizedBox(height: 20),

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
                  hint: 'Masukkan password Anda (minimal 6 karakter)',
                  icon: Icons.lock_outlined,
                  isPassword: !_isPasswordVisible,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                /// Confirm password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Password',
                  hint: 'Masukkan ulang password Anda',
                  icon: Icons.lock_outlined,
                  isPassword: !_isConfirmPasswordVisible,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Password tidak sama';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 32),

                /// Sign up button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      text: 'Daftar',
                      onPressed: authProvider.isLoading ? null : _handleSignUp,
                      isLoading: authProvider.isLoading,
                      icon: Icons.person_add,
                    );
                  },
                ),

                const SizedBox(height: 24),

                /// Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Masuk',
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

