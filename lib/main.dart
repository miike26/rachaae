import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa o User do Firebase Auth

// Importações de telas e serviços
import 'screens/profile_page.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'widgets/racha_card.dart';
import 'screens/create_racha_screen.dart';
import 'screens/racha_details_screen.dart';
import 'models/racha_model.dart';

// --- NOSSAS NOVAS IMPORTAÇÕES ---
import 'repositories/racha_repository.dart';
import 'repositories/local_storage_repository.dart';
import 'repositories/firestore_repository.dart';
// --- FIM DAS IMPORTAÇÕES ---

import 'utils/color_helper.dart';
import 'utils/material_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- MUDANÇA PRINCIPAL: MultiProvider ---
  // Agora fornecemos múltiplos serviços para a árvore de widgets.
  runApp(
    MultiProvider(
      providers: [
        // 1. Fornece o AuthService para que todos possam acessá-lo.
        ChangeNotifierProvider(create: (context) => AuthService()),

        // 2. Fornece o RachaRepository de forma dinâmica.
        // O ProxyProvider ouve o AuthService.
        ProxyProvider<AuthService, RachaRepository>(
          update: (context, authService, previousRepository) {
            // Se o usuário estiver logado (authService.user != null),
            // ele fornece o FirestoreRepository.
            // Se não, fornece o LocalStorageRepository.
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Racha Ae',
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
  
  late RachaRepository _rachaRepository;
  User? _currentUser;
  
  bool _isInit = true;

  bool _isLoading = true;
  String _userName = 'Você';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final authService = Provider.of<AuthService>(context);
    final newRepository = Provider.of<RachaRepository>(context);

    if (_isInit || _currentUser != authService.user) {
      final previousUser = _currentUser;
      _currentUser = authService.user;
      _rachaRepository = newRepository;
      
      // --- LÓGICA DE MIGRAÇÃO ---
      // Se o usuário acabou de fazer login (o anterior era nulo e o atual não é)
      if (previousUser == null && _currentUser != null) {
        _handleUserDataMigration().then((_) {
          // Após a lógica de migração (ou se não houver nada para migrar),
          // carregamos os dados da nova fonte (Firestore).
          _loadInitialData();
        });
      } else {
        // Para todos os outros casos (primeira carga, logout, etc.),
        // apenas carregamos os dados.
        _loadInitialData();
      }
      // --- FIM DA LÓGICA DE MIGRAÇÃO ---
      
      if (_isInit) {
        _isInit = false;
      }
    }
  }

  /// Lida com a verificação e migração de dados locais para o Firestore.
  Future<void> _handleUserDataMigration() async {
    final localRepo = LocalStorageRepository();
    final firestoreRepo = FirestoreRepository();

    final localRachas = await localRepo.getRachas();

    if (localRachas.isNotEmpty && mounted) {
      final shouldMigrate = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sincronizar dados?'),
            content: const Text('Encontramos rachas salvos no seu aparelho. Deseja movê-los para sua conta na nuvem?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Não, obrigado'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: const Text('Sim, mover'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (shouldMigrate == true && mounted) {
        setState(() { _isLoading = true; });

        try {
          for (final racha in localRachas) {
            await firestoreRepo.saveRacha(racha);
          }
          await localRepo.clearAllRachas();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dados sincronizados com sucesso!')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao sincronizar dados: $e')),
            );
          }
        }
      }
    }
  }

  Future<void> _loadInitialData() async {
    if (mounted) setState(() { _isLoading = true; });
    
    var loadedRachas = await _rachaRepository.getRachas();
    final loadedUserName = await _rachaRepository.loadUserName();

    if (mounted) {
      setState(() {
        _rachas = loadedRachas;
        _userName = loadedUserName;
        _isLoading = false;
      });
    }
  }

  void _navigateAndCreateRacha() async {
    final newRacha = await Navigator.push<Racha>(
      context,
      MaterialPageRoute(builder: (context) => const CreateRachaScreen()),
    );

    if (newRacha != null) {
      await _rachaRepository.saveRacha(newRacha);
      _loadInitialData();
    }
  }

  void _navigateToRachaDetails(Racha racha, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RachaDetailsScreen(racha: racha)),
    );

    if (result == 'delete') {
      await _rachaRepository.deleteRacha(racha.id);
      setState(() {
        _rachas.removeAt(index);
      });
    } else if (result is Racha) {
      await _rachaRepository.updateRacha(result);
      setState(() {
        _rachas[index] = result;
      });
    }
  }

  List<Widget> _getPages() {
    return [
      RachasPage(
        rachas: _rachas,
        onRachaTap: _navigateToRachaDetails,
        isLoading: _isLoading,
      ),
      AmigosPage(userName: _userName, rachas: _rachas),
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

// O restante do arquivo (RachasPage, AmigosPage) permanece o mesmo.
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
                if (rachas.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Text(
                        'Crie seu primeiro racha!',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ),
                  ),
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
