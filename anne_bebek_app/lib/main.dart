import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Providers
import 'shared/providers/baby_provider.dart';
import 'shared/providers/recommendations_provider.dart';
import 'shared/providers/culture_provider.dart';
import 'shared/providers/health_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/ad_provider.dart';
import 'shared/providers/astrology_provider.dart';

// Core
import 'core/constants/app_constants.dart';
import 'core/services/database_service.dart';
import 'core/services/network_service.dart';
import 'core/services/sync_service.dart';
import 'core/repositories/health_repository.dart';
import 'core/repositories/fake_health_repository.dart'; // Fake Repo
import 'core/repositories/recommendation_repository.dart';
import 'core/theme/app_theme.dart';

// Features
import 'features/auth/welcome_screen.dart';
import 'features/home/bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Servisleri başlat
  final dbService = DatabaseService.instance;
  final networkService = NetworkService();
  final syncService = SyncService(
    networkService: networkService,
    databaseService: dbService,
  );

  // Repository'leri başlat
  final healthRepo = FakeHealthRepository(); // Fake Repository kullanılıyor
  final recommendationRepo = RecommendationRepository(
    databaseService: dbService,
    networkService: networkService,
  );

  // System UI ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    AnneBebekApp(
      healthRepository: healthRepo,
      recommendationRepository: recommendationRepo,
    ),
  );
}

class AnneBebekApp extends StatelessWidget {
  final HealthRepository healthRepository;
  final RecommendationRepository recommendationRepository;

  const AnneBebekApp({
    super.key,
    required this.healthRepository,
    required this.recommendationRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              BabyProvider(databaseService: DatabaseService.instance),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              RecommendationsProvider(repository: recommendationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CultureProvider(databaseService: DatabaseService.instance),
        ),
        ChangeNotifierProvider(
          create: (_) => HealthProvider(repository: healthRepository),
        ),
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(create: (_) => AstrologyProvider()),
        ChangeNotifierProxyProvider<BabyProvider, RecommendationsProvider>(
          create: (_) =>
              RecommendationsProvider(repository: recommendationRepository),
          update: (_, babyProvider, recommendationsProvider) {
            if (babyProvider.currentBaby != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                recommendationsProvider?.updateTodayRecommendations(
                  babyProvider,
                );
                recommendationsProvider?.updateThisWeekRecommendations(
                  babyProvider,
                );
              });
            }
            return recommendationsProvider ??
                RecommendationsProvider(repository: recommendationRepository);
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('tr', 'TR')],
            locale: const Locale('tr', 'TR'),
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

// ... (Rest of the file remains the same: AppInitializer, SplashScreen, ErrorScreen)
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Build tamamlandıktan sonra initialize çağır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final recommendationsProvider = Provider.of<RecommendationsProvider>(
        context,
        listen: false,
      );
      final cultureProvider = Provider.of<CultureProvider>(
        context,
        listen: false,
      );
      final adProvider = Provider.of<AdProvider>(context, listen: false);

      await babyProvider.initialize();
      await cultureProvider.initialize();
      await adProvider.initialize();

      if (babyProvider.currentBaby?.id != null) {
        await recommendationsProvider.initialize(
          babyProvider.currentBaby!.id!.toString(),
        );
      }

      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Uygulama başlatılırken hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BabyProvider>(
      builder: (context, babyProvider, child) {
        if (babyProvider.isLoading) {
          return const SplashScreen();
        }

        if (babyProvider.errorMessage != null) {
          return ErrorScreen(
            message: babyProvider.errorMessage!,
            onRetry: () => _initializeApp(),
          );
        }

        if (babyProvider.hasBabyProfile) {
          return const MainBottomNavigation();
        } else {
          return const WelcomeScreen(showOnboarding: true);
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.baby_changing_station_rounded,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bebeğinizle birlikte büyüyoruz',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorScreen({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Bir Hata Oluştu',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
