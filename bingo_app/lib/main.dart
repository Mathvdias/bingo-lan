import 'package:bingo_app/shared/router.dart';
import 'package:bingo_app/shared/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

void main() async {
  // Ensure Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize the Bingo SDK
  // Using placeholder keys for now. These should be stored securely.
  await BingoSDK.initialize(
    supabaseUrl: "YOUR_SUPABASE_URL",
    supabaseKey: "YOUR_SUPABASE_KEY",
    revenueCatKey: "YOUR_REVENUECAT_KEY",
  );

  // 2. Fetch and activate remote feature flags.
  final config = GetIt.I.get<IConfigDriver>();
  await config.fetchAndActivate();

  // Run the main Flutter application.
  runApp(const BingoApp());
}

class BingoApp extends StatelessWidget {
  const BingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bingo Lucca',
      theme: bingoTheme,
      routerConfig: router,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate app initialization and then navigate to the lobby.
    Future.delayed(const Duration(seconds: 2), () {
      // It's important to check if the widget is still mounted before navigating.
      if (mounted) {
        context.go('/lobby');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Inicializando o Bingo..."),
          ],
        ),
      ),
    );
  }
}
