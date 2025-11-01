import 'package:flutter/material.dart';

/// Onboarding Page Widget
/// Widget untuk menampilkan satu halaman onboarding
/// Mengikuti konsep Reusability dan Single Responsibility Principle
class OnboardingPage extends StatelessWidget {
  /// Path image untuk onboarding page
  final String imagePath;

  /// Title untuk onboarding page
  final String title;

  /// Description untuk onboarding page
  final String description;

  /// Constructor untuk OnboardingPage
  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  /// Build method untuk membuat widget
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Image dengan error handling
          Image.asset(
            imagePath,
            height: 300,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              /// Jika gambar tidak ditemukan, tampilkan placeholder
              return Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gambar tidak ditemukan',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 48),

          /// Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          /// Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

