import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/mock/mock_config.dart';
import 'shared/themes/app_theme.dart';

/// Main App Widget
/// Widget utama aplikasi dengan konfigurasi tema dan routing
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // FORCE DISABLE MOCK MODE - Always use real API
    _initApp();
  }

  Future<void> _initApp() async {
    // Disable mock mode immediately on app start
    await MockConfig().setMockMode(false);
    print('✅ MOCK MODE DISABLED - Using REAL API');
  }
  
  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router(ref);
    
    return MaterialApp.router(
      title: 'Pondok Terapi Bicara',
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // You can make this dynamic later
      
      // Router Configuration
      routerConfig: router,
      
      // Localization (optional)
      locale: const Locale('id', 'ID'),
      supportedLocales: const [
        Locale('id', 'ID'), // Indonesian
        Locale('en', 'US'), // English
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Builder for additional configurations
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scale factor doesn't exceed 1.3 for better UI consistency
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.textScalerOf(context).scale(1).clamp(0.8, 1.3),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}