import 'package:flutter/material.dart';
import '../../shared/widgets/fade_in_animation.dart';
import '../../shared/widgets/slide_up_animation.dart';
import '../../shared/widgets/scale_animation.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/shimmer_effect.dart';
import '../../shared/widgets/progress_indicators.dart';
import '../../shared/widgets/responsive_layout.dart';
import '../../shared/widgets/adaptive_card.dart';
import '../../shared/widgets/touch_feedback.dart';
import '../../shared/widgets/accessibility_widgets.dart';
import '../../shared/widgets/performance_widgets.dart';
import '../../core/constants/app_constants.dart';

class UIDemoScreen extends StatefulWidget {
  const UIDemoScreen({super.key});

  @override
  State<UIDemoScreen> createState() => _UIDemoScreenState();
}

class _UIDemoScreenState extends State<UIDemoScreen> {
  bool _showSkeleton = true;
  int _currentDemoIndex = 0;

  final List<String> _demoTitles = [
    'Animasyon Sistemi',
    'Loading Bileşenleri',
    'Responsive Tasarım',
    'Touch Feedback',
    'Accessibility',
    'Performance',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI/UX Demo'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetDemo),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo selector
            _buildDemoSelector(),

            const SizedBox(height: 24),

            // Current demo content
            _buildCurrentDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Demo Seçici',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_demoTitles.length, (index) {
            return FilterChip(
              label: Text(_demoTitles[index]),
              selected: _currentDemoIndex == index,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentDemoIndex = index;
                  });
                }
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCurrentDemo() {
    switch (_currentDemoIndex) {
      case 0:
        return _buildAnimationDemo();
      case 1:
        return _buildLoadingDemo();
      case 2:
        return _buildResponsiveDemo();
      case 3:
        return _buildTouchFeedbackDemo();
      case 4:
        return _buildAccessibilityDemo();
      case 5:
        return _buildPerformanceDemo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAnimationDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Animasyon Sistemi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Fade In Animation
        const Text('Fade In Animation:'),
        FadeInAnimation(
          delay: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade100,
            child: const Text('Bu widget fade in animasyonu ile görünüyor!'),
          ),
        ),

        const SizedBox(height: 24),

        // Slide Up Animation
        const Text('Slide Up Animation:'),
        SlideUpAnimation(
          delay: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade100,
            child: const Text('Bu widget yukarı kayarak görünüyor!'),
          ),
        ),

        const SizedBox(height: 24),

        // Scale Animation
        const Text('Scale Animation:'),
        ScaleAnimation(
          delay: const Duration(milliseconds: 600),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade100,
            child: const Text('Bu widget büyüyerek görünüyor!'),
          ),
        ),

        const SizedBox(height: 24),

        // Staggered Animation
        const Text('Staggered Animation:'),
        StaggeredFadeInAnimation(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.purple.shade100,
              child: const Text('İlk öğe'),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.pink.shade100,
              child: const Text('İkinci öğe'),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.teal.shade100,
              child: const Text('Üçüncü öğe'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loading Bileşenleri',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Skeleton Loader
        Row(
          children: [
            const Text('Skeleton Loader:'),
            const SizedBox(width: 16),
            Switch(
              value: _showSkeleton,
              onChanged: (value) {
                setState(() {
                  _showSkeleton = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_showSkeleton) ...[
          const SkeletonText(lines: 3),
          const SizedBox(height: 16),
          Row(
            children: [
              const SkeletonLoader(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    SkeletonLoader(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoader(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          const Text('Skeleton loader devre dışı'),
        ],

        const SizedBox(height: 24),

        // Shimmer Effect
        const Text('Shimmer Effect:'),
        const SizedBox(height: 12),
        ShimmerEffect(
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('Shimmer efekti uygulandı!')),
          ),
        ),

        const SizedBox(height: 24),

        // Progress Indicators
        const Text('Progress Indicators:'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Circular', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  AnimatedCircularProgressIndicator(value: 0.7),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  const Text('Linear', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  AnimatedLinearProgressIndicator(value: 0.7),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  const Text('Dots', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  const DotsProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResponsiveDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Responsive Tasarım',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Screen size info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ekran Boyutu: ${context.screenSize.name}'),
              Text('Genişlik: ${context.screenWidth.toInt()}px'),
              Text('Yükseklik: ${context.screenHeight.toInt()}px'),
              Text('Tablet veya daha büyük: ${context.isTabletOrLarger}'),
              Text('Desktop: ${context.isDesktop}'),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Responsive Layout
        const Text('Responsive Layout:'),
        const SizedBox(height: 12),
        ResponsiveLayout(
          small: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade100,
            child: const Text('Küçük ekran layout'),
          ),
          medium: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade100,
            child: const Text('Orta ekran layout'),
          ),
          large: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade100,
            child: const Text('Büyük ekran layout'),
          ),
        ),

        const SizedBox(height: 24),

        // Adaptive Card
        const Text('Adaptive Card:'),
        const SizedBox(height: 12),
        AdaptiveCard(
          title: const Text('Adaptive Card Başlığı'),
          subtitle: const Text('Bu kart ekran boyutuna göre kendini uyarlar'),
          content: const Text(
            'İçerik burada yer alır ve responsive olarak düzenlenir.',
          ),
          actions: [
            TextButton(onPressed: () {}, child: const Text('İptal')),
            ElevatedButton(onPressed: () {}, child: const Text('Tamam')),
          ],
        ),
      ],
    );
  }

  Widget _buildTouchFeedbackDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Touch Feedback',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Touch Feedback Button
        const Text('Touch Feedback Button:'),
        const SizedBox(height: 12),
        TouchFeedback(
          onTap: () => _showSnackBar('Touch feedback ile tıklandı!'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Beni Dokun!',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Swipe Feedback
        const Text('Swipe Feedback:'),
        const SizedBox(height: 12),
        SwipeFeedback(
          onSwipeLeft: () => _showSnackBar('Sola kaydırıldı!'),
          onSwipeRight: () => _showSnackBar('Sağa kaydırıldı!'),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Sola veya sağa kaydırın',
              textAlign: TextAlign.center,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Smooth Scroll View
        const Text('Smooth Scroll View:'),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: SmoothScrollView(
            children: List.generate(
              10,
              (index) => Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors
                      .primaries[index % Colors.primaries.length]
                      .shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Öğe ${index + 1}'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessibilityDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accessibility',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Accessible Button
        const Text('Accessible Button:'),
        const SizedBox(height: 12),
        AccessibleButton(
          onPressed: () => _showSnackBar('Accessible button tıklandı!'),
          semanticLabel: 'Demo butonu',
          child: const Text('Accessible Button'),
        ),

        const SizedBox(height: 24),

        // Accessible Text
        const Text('Accessible Text:'),
        const SizedBox(height: 12),
        const AccessibleText(
          'Bu metin screen reader için optimize edilmiştir.',
          style: TextStyle(fontSize: 16),
        ),

        const SizedBox(height: 24),

        // Accessible Card
        const Text('Accessible Card:'),
        const SizedBox(height: 12),
        AccessibleCard(
          semanticLabel: 'Demo kartı',
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kart Başlığı',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Kart açıklaması'),
                SizedBox(height: 12),
                Text('Bu kart accessibility özelliklerine sahip.'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Accessible Switch
        const Text('Accessible Switch:'),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Demo Switch:'),
            const SizedBox(width: 16),
            AccessibleSwitch(
              value: _showSkeleton,
              onChanged: (value) {
                setState(() {
                  _showSkeleton = value;
                });
              },
              semanticLabel: 'Demo switch',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Optimizasyonları',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Performance Animated Widget
        const Text('Performance Animated Widget:'),
        const SizedBox(height: 12),
        const PerformanceAnimatedWidget(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Bu widget performans için optimize edilmiş'),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Optimized List View
        const Text('Optimized List View:'),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: OptimizedListView(
            children: List.generate(
              20,
              (index) => ListTile(
                title: Text('Öğe ${index + 1}'),
                subtitle: Text('Optimize edilmiş liste öğesi ${index + 1}'),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Performance Monitor (only in debug mode)
        if (true) ...[
          // Debug mode check - replace with proper debug check
          const Text('Performance Monitor:'),
          const SizedBox(height: 12),
          const PerformanceMonitor(
            showFPS: true,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('FPS monitor aktif'),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Device info
        const Text('Device Performance Info:'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Low-end device: ${PerformanceUtils.isLowEndDevice(context)}',
              ),
              Text(
                'Optimal animation duration: ${PerformanceUtils.getOptimalAnimationDuration(context).inMilliseconds}ms',
              ),
              Text(
                'Performance mode: ${PerformanceUtils.shouldEnablePerformanceMode(context)}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetDemo() {
    setState(() {
      _showSkeleton = true;
      _currentDemoIndex = 0;
    });
  }
}
