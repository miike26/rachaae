import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Importa o Provider
import 'package:firebase_core/firebase_core.dart'; // Importa o Firebase Core

// Importações de telas e serviços
import 'screens/profile_page.dart'; // Importa a nova página de perfil
import 'firebase_options.dart'; // Importa a configuração do Firebase
import 'services/auth_service.dart'; // Importa o serviço de autenticação
import 'widgets/racha_card.dart';
import 'screens/create_racha_screen.dart';
import 'screens/racha_details_screen.dart';
import 'models/racha_model.dart';
//import 'models/expense_model.dart';
import 'services/storage_service.dart';
import 'utils/color_helper.dart';
import 'utils/material_theme.dart';

void main() async {
  // Garante que o Flutter está pronto e inicializa o Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Envolve o aplicativo com o ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Racha Ae',
      // Seu tema original foi mantido
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: MaterialTheme.lightMediumContrastScheme(),
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        cardTheme: CardThemeData(
          elevation: 1,
          color: const Color(0xFFFFFFFF),
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Racha> _rachas = [];
  final StorageService _storageService = StorageService();
  bool _isLoading = true;
  String _userName = 'Você';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // A lógica de carregar dados foi mantida, mas a criação de mocks foi removida
    // para um comportamento mais real do app.
    var loadedRachas = await _storageService.loadRachas();
    final loadedUserName = await _storageService.loadUserName();

    setState(() {
      _rachas = loadedRachas;
      _userName = loadedUserName;
      _isLoading = false;
    });
  }

  Future<void> _saveRachasToStorage() async {
    await _storageService.saveRachas(_rachas);
  }

  // A função _saveUserName foi removida pois não era mais referenciada.
  // A nova PerfilPage gerencia o estado do usuário (logado ou não).

  void _navigateAndCreateRacha() async {
    final newRacha = await Navigator.push<Racha>(
      context,
      MaterialPageRoute(builder: (context) => const CreateRachaScreen()),
    );

    if (newRacha != null) {
      setState(() {
        _rachas.insert(0, newRacha);
      });
      await _saveRachasToStorage();

      if (mounted) {
        _navigateToRachaDetails(newRacha, 0);
      }
    }
  }

  void _navigateToRachaDetails(Racha racha, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RachaDetailsScreen(racha: racha)),
    );

    setState(() {
      if (result == 'delete') {
        _rachas.removeAt(index);
      } else if (result is Racha) {
        _rachas[index] = result;
      }
    });
    _saveRachasToStorage();
  }

  List<Widget> _getPages() {
    return [
      RachasPage(
        rachas: _rachas,
        onRachaTap: _navigateToRachaDetails,
        isLoading: _isLoading,
      ),
      AmigosPage(userName: _userName, rachas: _rachas),
      // AQUI ESTÁ A MUDANÇA PRINCIPAL:
      // Usamos a nova PerfilPage importada, que já tem a lógica de login.
      const PerfilPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();
    return Scaffold(
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateAndCreateRacha,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Rachas'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Amigos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// O widget RachasPage foi mantido como estava no seu código original
class RachasPage extends StatelessWidget {
  final List<Racha> rachas;
  final Function(Racha, int) onRachaTap;
  final bool isLoading;

  const RachasPage({
    super.key,
    required this.rachas,
    required this.onRachaTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final openRachas = rachas.where((r) => !r.isFinished).toList();
    final finishedRachas = rachas.where((r) => r.isFinished).toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text('Meus Rachas', style: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (openRachas.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text('EM ABERTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  ...openRachas.map((racha) {
                    final index = rachas.indexOf(racha);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: RachaCard(
                        racha: racha,
                        onTap: () => onRachaTap(racha, index),
                      ),
                    );
                  }).toList().animate(interval: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2),
                ],
                if (finishedRachas.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text('FINALIZADOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  ...finishedRachas.map((racha) {
                    final index = rachas.indexOf(racha);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Opacity(
                        opacity: 0.7,
                        child: RachaCard(
                          racha: racha,
                          onTap: () => onRachaTap(racha, index),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
    );
  }
}

// O widget AmigosPage foi mantido como estava no seu código original
class AmigosPage extends StatelessWidget {
  final String userName;
  final List<Racha> rachas;
  const AmigosPage({super.key, required this.userName, required this.rachas});

  @override
  Widget build(BuildContext context) {
    final allFriends = rachas
        .expand((racha) => racha.participants)
        .toSet()
        .where((name) => name != userName)
        .toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text('Amigos', style: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(icon: const Icon(Icons.person_add_alt_1), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allFriends.length,
        itemBuilder: (context, index) {
          final friendName = allFriends[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: ColorHelper.getColorForName(friendName),
                child: Text(
                  friendName.isNotEmpty ? friendName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(friendName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}

// A classe PerfilPage antiga foi removida daqui.
// Agora o app usará a nova versão que está em 'lib/screens/profile_page.dart'.
