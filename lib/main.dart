import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Importações de telas e serviços
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'repositories/racha_repository.dart';
import 'repositories/local_storage_repository.dart';
import 'repositories/firestore_repository.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart'; // Importa o novo arquivo de tema
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsService()),
        ChangeNotifierProvider(create: (context) => AuthService()),
        Provider(create: (context) => UserService()),
        ProxyProvider<AuthService, RachaRepository>(
          update: (context, authService, previousRepository) {
            return authService.user != null
                ? FirestoreRepository()
                : LocalStorageRepository();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // O Consumer<SettingsService> agora controla o tema do MaterialApp
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Racha Ae',
          theme: AppTheme.lightTheme, // Define o tema claro
          darkTheme: AppTheme.darkTheme, // Define o tema escuro
          themeMode: settings.themeMode, // Usa o ThemeMode do serviço
          home: const HomeScreen(),
        );
      },
    );
  }
}
