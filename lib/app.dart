import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'shared/themes/app_theme.dart';

/// Main App Widget
/// Widget utama aplikasi dengan konfigurasi tema dan routing
class App extends ConsumerWidget {
  const App({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter.router(ref);
    
    return MaterialApp.router(
      title: 'Speech Therapy',
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