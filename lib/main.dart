import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userName = prefs.getString('userName') ?? 'Admin';
  final userEmail = prefs.getString('userEmail') ?? 'admin@example.com';

  runApp(
    ProviderScope(
      child: MyApp(
        isLoggedIn: isLoggedIn,
        userName: userName,
        userEmail: userEmail,
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool isLoggedIn;
  final String userName;
  final String userEmail;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Kula Theivam',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E1B4B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E1B4B),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: isLoggedIn
          ? DashboardScreen(userName: userName, userEmail: userEmail)
          : LoginScreen(),
    );
  }
}
