import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/onboarding_page.dart';

/// Onboarding Screen
/// Menampilkan 3 halaman onboarding untuk memperkenalkan aplikasi
/// Mengikuti konsep Single Responsibility Principle
class OnboardingScreen extends StatefulWidget {
  /// Constructor untuk OnboardingScreen
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// Page controller untuk mengelola halaman onboarding
  final PageController _pageController = PageController();

  /// Index halaman saat ini (0, 1, atau 2)
  int _currentPage = 0;

  /// Method untuk move ke halaman berikutnya
  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      /// Jika sudah di halaman terakhir, navigate ke login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  /// Method untuk skip onboarding
  void _skipOnboarding() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  /// Method untuk dispose resources
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Build method untuk membuat widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            /// Skip button di pojok kanan atas
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Lewati',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),

            /// Expanded untuk PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: const [
                  /// Halaman 1: Intro aplikasi
                  OnboardingPage(
                    imagePath: 'assets/images/onboarding_1.png',
                    title: 'Kelola Waktu Bermain Sosmed',
                    description:
                        'Aplikasi SosialBreak membantu Anda mengelola waktu bermain media sosial dengan lebih baik dan produktif.',
                  ),

                  /// Halaman 2: Fitur challenge
                  OnboardingPage(
                    imagePath: 'assets/images/onboarding_2.png',
                    title: 'Ikuti Challenge Menarik',
                    description:
                        'Ikuti berbagai challenge untuk mengurangi waktu bermain sosmed dan dapatkan rewards menarik.',
                  ),

                  /// Halaman 3: Track progress
                  OnboardingPage(
                    imagePath: 'assets/images/onboarding_3.png',
                    title: 'Lacak Progress Anda',
                    description:
                        'Pantau progress dan streak Anda setiap hari untuk tetap termotivasi dalam mengurangi waktu bermain sosmed.',
                  ),
                ],
              ),
            ),

            /// Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            /// Next button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage < 2 ? 'Selanjutnya' : 'Mulai Sekarang',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

