import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  bool _isLoading = false;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  XFile? _selectedXFile; // Simpan XFile untuk upload (path lebih reliable)
  Uint8List? _selectedImageBytes; // Simpan bytes untuk preview
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        // Baca bytes untuk preview
        final imageBytes = await image.readAsBytes();
        setState(() {
          _selectedXFile = image; // Simpan XFile untuk upload (path lebih reliable)
          _selectedImageBytes = imageBytes; // Simpan bytes untuk preview
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User tidak ditemukan. Silakan login ulang.')),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    // Upload gambar jika ada gambar yang dipilih
    String? avatarUrl = currentUser.avatarUrl;
    if (_selectedXFile != null) {
      // Coba upload menggunakan path dari XFile dulu (lebih efisien, tidak perlu path_provider)
      bool uploadSuccess = await authProvider.uploadAvatar(_selectedXFile!.path);
      
      // Jika gagal dengan path, coba dengan bytes sebagai fallback
      if (!uploadSuccess && _selectedImageBytes != null) {
        // Cek apakah error karena path atau masalah lain
        if (authProvider.error?.contains('tidak ditemukan') == true ||
            authProvider.error?.contains('MissingPlugin') == true) {
          // Coba dengan bytes
          uploadSuccess = await authProvider.uploadAvatarBytes(_selectedImageBytes!);
        }
      }
      
      if (!uploadSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Gagal mengupload gambar.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
        return;
      }
      // Ambil avatar URL dari current user yang sudah diupdate
      avatarUrl = authProvider.currentUser?.avatarUrl;
    }

    final newEmail = _emailController.text.trim();
    final emailChanged = newEmail != currentUser.email;

    // Jika email berubah, update email terlebih dahulu
    if (emailChanged) {
      final emailSuccess = await authProvider.updateEmail(newEmail);
      if (!emailSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Gagal memperbarui email.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
        return;
      }
    }

    // Buat user yang diupdate dengan data baru
    final updatedUser = currentUser.copyWith(
      email: newEmail,
      fullName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
      avatarUrl: avatarUrl,
    );

    // Update ke Supabase melalui provider
    final success = await authProvider.updateUser(updatedUser);

    if (mounted) {
      if (success) {
        // Refresh current user untuk memastikan data terbaru dari Supabase
        await authProvider.getCurrentUser();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        // Return true untuk memberi tahu parent screen bahwa update berhasil
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Gagal memperbarui profil.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isChangingPassword = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.changePassword(
      currentPassword: _currentPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    if (mounted) {
      if (success) {
        // Clear password fields setelah berhasil
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diubah!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Gagal mengubah password.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isChangingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form Edit Profil
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Informasi Profil',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Upload Avatar Section
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                              backgroundImage: _selectedImageBytes != null
                                  ? MemoryImage(_selectedImageBytes!)
                                  : (context.watch<AuthProvider>().currentUser?.avatarUrl != null &&
                                          context.watch<AuthProvider>().currentUser!.avatarUrl!.isNotEmpty
                                      ? NetworkImage(context.watch<AuthProvider>().currentUser!.avatarUrl!)
                                      : null) as ImageProvider?,
                              child: _selectedImageBytes == null &&
                                      (context.watch<AuthProvider>().currentUser?.avatarUrl == null ||
                                          context.watch<AuthProvider>().currentUser!.avatarUrl!.isEmpty)
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Theme.of(context).colorScheme.primary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                  onPressed: _pickImage,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Pilih Foto Profil'),
                        ),
                      ],
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      hintText: 'Masukkan nama lengkap Anda',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
                        return 'Nama minimal 2 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Masukkan username Anda',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                    textCapitalization: TextCapitalization.none,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.trim().length < 3) {
                          return 'Username minimal 3 karakter';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                          return 'Username hanya boleh huruf, angka, dan underscore';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Masukkan email Anda',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Simpan Perubahan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            // Form Ubah Password
            Form(
              key: _passwordFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ubah Password',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Password Saat Ini',
                      hintText: 'Masukkan password saat ini',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrentPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureCurrentPassword,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password saat ini tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      hintText: 'Masukkan password baru',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureNewPassword,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password baru tidak boleh kosong';
                      }
                      if (value.trim().length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      hintText: 'Ulangi password baru',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_clock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Konfirmasi password tidak boleh kosong';
                      }
                      if (value.trim() != _newPasswordController.text.trim()) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: _isChangingPassword ? null : _changePassword,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isChangingPassword
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Ubah Password'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}