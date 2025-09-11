import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quit_smoking_app/services/storage_services.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'utils/app_theme.dart';

class SmokingQuitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quit Smoking Assistant',
      theme: AppTheme.lightTheme,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ar', 'EG'), // Arabic (Egypt)
        const Locale('en', 'US'), // English (US)
      ],
      locale: const Locale('ar', 'EG'),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: StorageService.isFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          }

          if (snapshot.data == true) {
            return SetupScreen();
          } else {
            return HomeScreen();
          }
        },
      ),
      routes: {
        '/home': (context) => HomeScreen(),
        '/setup': (context) => SetupScreen(),
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.smoke_free,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 30),
              const Text(
                'Quit Smoking Assistant',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
