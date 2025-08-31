import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/baby_provider.dart';
import 'home_screen.dart';
import '../health/health_dashboard_screen.dart';
import '../recommendations/recommendations_screen.dart';
import '../culture/culture_screen.dart';
import '../settings/settings_screen.dart';

class MainBottomNavigation extends StatefulWidget {
  final int initialIndex;
  const MainBottomNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainBottomNavigation> createState() => _MainBottomNavigationState();
}

class _MainBottomNavigationState extends State<MainBottomNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: AppConstants.shortAnimation,
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BabyProvider>(
      builder: (context, babyProvider, child) {
        // Bebek profili yoksa ana dashboard'a yönlendir
        if (!babyProvider.hasBabyProfile) {
          return const HomeScreen();
        }

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              HomeScreen(),
              HealthDashboardScreen(),
              RecommendationsScreen(),
              CultureScreen(),
              SettingsScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 74,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_rounded,
                      label: 'Ana Sayfa',
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.favorite_rounded,
                      label: 'Sağlık',
                      index: 1,
                    ),
                    _buildNavItem(
                      icon: Icons.lightbulb_rounded,
                      label: 'Öneriler',
                      index: 2,
                    ),
                    _buildNavItem(
                      icon: Icons.public_rounded,
                      label: 'Kültür',
                      index: 3,
                    ),
                    _buildNavItem(
                      icon: Icons.person_rounded,
                      label: 'Profil',
                      index: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withAlpha(26)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withAlpha(153),
              size: isSelected ? 24 : 22,
            ),
            const SizedBox(height: 1),
            AnimatedDefaultTextStyle(
              duration: AppConstants.shortAnimation,
              style: theme.textTheme.labelSmall!.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withAlpha(153),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// Navigation Keys Global Navigator için
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Bottom Navigation Helper
class BottomNavHelper {
  static void navigateToTab(BuildContext context, int index) {
    final navState = context
        .findAncestorStateOfType<_MainBottomNavigationState>();
    navState?._onTabTapped(index);
  }
}
