import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';
import 'controllers/notes_controller.dart';
import 'firebase_options.dart';
import 'views/auth/login_screen.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Graceful fallback to offline/demo mode if platform credentials are not yet linked
  }
  runApp(const NotasApp());
}

class NotasApp extends StatefulWidget {
  final AuthController? authController;
  final NotesController? notesController;

  const NotasApp({
    super.key,
    this.authController,
    this.notesController,
  });

  @override
  State<NotasApp> createState() => _NotasAppState();
}

class _NotasAppState extends State<NotasApp> {
  late final AuthController _authController;
  late final NotesController _notesController;
  String? _lastLoadedUserId;

  @override
  void initState() {
    super.initState();
    _authController = widget.authController ?? AuthController();
    _notesController = widget.notesController ?? NotesController();
  }

  @override
  void dispose() {
    if (widget.authController == null) {
      _authController.dispose();
    }
    if (widget.notesController == null) {
      _notesController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9F9FB),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFFF9F9FB),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF14161D),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFF14161D),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: ListenableBuilder(
        listenable: _authController,
        builder: (context, _) {
          if (_authController.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (!_authController.isAuthenticated) {
            _lastLoadedUserId = null;
            return LoginScreen(authController: _authController);
          }

          final user = _authController.currentUser!;
          if (_lastLoadedUserId != user.uid) {
            _lastLoadedUserId = user.uid;
            _notesController.setUser(user);
          }

          return HomeScreen(
            controller: _notesController,
            authController: _authController,
          );
        },
      ),
    );
  }
}
