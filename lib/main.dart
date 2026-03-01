// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/feed_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

bool _firebaseReady = false;
String? _firebaseError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    // Activate App Check so Cloud Functions accept our requests.
    // debug provider works in dev; swap to playIntegrity for production.
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
    _firebaseReady = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    _firebaseReady = false;
    _firebaseError = e.toString();
    debugPrint('❌ Firebase init failed: $e');
  }
  runApp(MaxRepApp(firebaseReady: _firebaseReady));
}

class MaxRepApp extends StatelessWidget {
  final bool firebaseReady;
  const MaxRepApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    // demoMode = Firebase could not initialize
    final bool demoMode = !firebaseReady;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserAuthProvider(demoMode: demoMode)),
        ChangeNotifierProvider(create: (_) => FeedProvider(demoMode: demoMode)),
      ],
      child: MaterialApp(
        title: 'MaxRep',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: firebaseReady
            ? const AppRouter()
            : _FirebaseErrorBanner(
                error: _firebaseError,
                child: const AppRouter(),
              ),
      ),
    );
  }
}

/// Root router that listens to [UserAuthProvider] and navigates accordingly.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<UserAuthProvider>();

    switch (auth.status) {
      case AuthStatus.unknown:
        return const SplashScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.profileIncomplete:
        return const ProfileSetupScreen();
      case AuthStatus.authenticated:
        final demoMode = auth.demoMode;
        return HomeScreen(demoMode: demoMode);
    }
  }
}

/// Shows a thin banner when Firebase couldn't be configured,
/// but still lets you browse the full UI with demo data.
class _FirebaseErrorBanner extends StatelessWidget {
  final String? error;
  final Widget child;
  const _FirebaseErrorBanner({this.error, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // This SafeArea banner appears at the very top over any screen
        SafeArea(
          child: GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppTheme.surface,
                title: const Text('Firebase Not Connected',
                    style: TextStyle(color: AppTheme.textPrimary)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Check:\n'
                      '• google-services.json is in android/app/\n'
                      '• Package name matches your Firebase project\n'
                      '• Authentication is enabled in Firebase Console\n\n'
                      'Running in Demo Mode with mock data.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                      ),
                    ]
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK', style: TextStyle(color: AppTheme.primary)),
                  ),
                ],
              ),
            ),
            child: Container(
              width: double.infinity,
              color: Colors.orange.shade900.withValues(alpha: 0.95),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: const Text(
                '⚠ Firebase not connected — Demo Mode  (tap for details)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
