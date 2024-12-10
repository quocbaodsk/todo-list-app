import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/screens/auth/login_screen.dart';
import 'package:todo_list/screens/main/home_screen.dart';
import 'package:todo_list/screens/main/task_detail_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/task_provider.dart';
import 'providers/weather_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Todo App',
            routes: {
              '/home': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
            },
            onGenerateRoute: (RouteSettings settings) {
              final uri = Uri.parse(settings.name ?? '');

              if (uri.pathSegments.length == 2 &&
                  uri.pathSegments.first == 'task-detail') {
                final id = int.tryParse(uri.pathSegments[1]);
                if (id != null) {
                  final task = context.read<TaskProvider>().getTaskById(id);
                  if (task != null) {
                    return MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(task: task),
                    );
                  }
                }
              }

              if (uri.pathSegments.length == 2 &&
                  uri.pathSegments.first == 'weather-detail') {
                final id = int.tryParse(uri.pathSegments[1]);
                if (id != null) {
                  final task = context.read<TaskProvider>().getTaskById(id);
                  if (task != null) {
                    return MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(task: task),
                    );
                  }
                }
              }

              return null;
            },
            debugShowCheckedModeBanner: true,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.beVietnamProTextTheme(),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                brightness: Brightness.dark,
              ),
              textTheme:
                  GoogleFonts.beVietnamProTextTheme(ThemeData.dark().textTheme),
            ),
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _checkAuthFuture;

  @override
  void initState() {
    super.initState();
    _checkAuthFuture = context.read<AuthProvider>().checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuthFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Lottie.asset('assets/animations/loading.json'),
            ),
          );
        }

        final isAuthenticated = snapshot.data ?? false;
        return isAuthenticated ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
