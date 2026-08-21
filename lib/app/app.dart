import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/common/connectivity_banner.dart';
import '../widgets/common/loading_error_states.dart';
import 'main_shell.dart';
import 'theme/app_theme.dart';

class BmiApp extends StatelessWidget {
  const BmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: ConnectivityBanner(
        child: switch (auth.status) {
          AuthStatus.unknown => const Scaffold(body: LoadingState()),
          AuthStatus.authenticated => const MainShell(),
          AuthStatus.unauthenticated => const LoginScreen(),
        },
      ),
    );
  }
}
