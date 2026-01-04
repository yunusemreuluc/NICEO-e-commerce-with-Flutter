import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'pages/main_layout.dart';
import 'services/cart_service.dart';
import 'services/favorite_service.dart';
import 'services/notification_service.dart';
import 'services/app_settings_service.dart';
import 'services/review_service.dart';

// Yeni servisler
import 'services/auth_service.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sistemin UI overlay ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.dark, // AppBarTheme ile darkta light’a dönecek
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const NiceoApp());
}

class NiceoApp extends StatelessWidget {
  const NiceoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthService'i ekledik - init() provider içinde çağrılıyor
        ChangeNotifierProvider(
          create: (_) {
            final s = AuthService();
            s.init(); // async init() içinde token kontrolü yapar
            return s;
          },
        ),

        // Mevcut servisler (yapını bozmadım)
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => FavoriteService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => AppSettingsService()),
        ChangeNotifierProvider(create: (_) => ReviewService()),
      ],
      // ⬇️ AppSettingsService'i dinleyerek MaterialApp'ı kur
      child: Consumer<AppSettingsService>(
        builder: (context, settings, _) {
          final lightTheme = ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFFFF6B81),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF6B81),
            ),
            scaffoldBackgroundColor: const Color(0xFFF7F8FA),
            fontFamily: 'Inter',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );

          final darkTheme = ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF6B81),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0B1220),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F172A),
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            fontFamily: 'Inter',
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NICEO',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settings.themeMode, // ✅ Açık/Koyu/Sistem
            locale: settings.locale, // ✅ TR/EN
            supportedLocales: const [Locale('tr'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // başlangıç ekranı: auth durumuna göre EntryPage seçer
            home: const EntryPage(),
          );
        },
      ),
    );
  }
}

/// EntryPage: AuthService durumuna göre Login veya MainLayout gösterir
class EntryPage extends StatelessWidget {
  const EntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    if (auth.initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // artık otomatik login kapalı -> her zaman LoginPage gösterilecek
    return auth.loggedIn ? const MainLayout() : const LoginPage();
  }
}
