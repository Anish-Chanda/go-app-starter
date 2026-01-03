import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router.dart';
import 'theme.dart';
import 'services/http.dart';
import 'providers/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HTTP client with API base URL
  await HttpClient.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkSession()),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          return MaterialApp.router(
            title: 'Flutter App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: createRouter(authProvider),
          );
        },
      ),
    );
  }
}
