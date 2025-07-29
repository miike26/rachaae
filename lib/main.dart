import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importações de telas e serviços
import 'screens/profile_page.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'widgets/racha_card.dart';
import 'screens/create_racha_screen.dart';
import 'screens/racha_details_screen.dart';
import 'models/racha_model.dart';

// Repositórios e outros serviços
import 'repositories/racha_repository.dart';
import 'repositories/local_storage_repository.dart';
import 'repositories/firestore_repository.dart';
import 'widgets/add_friend_dialog.dart'; 
import 'services/user_service.dart'; 
import 'models/user_model.dart'; 
import 'models/friend_request_model.dart'; 

import 'utils/color_helper.dart';
import 'utils/material_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final authService = Provider.of<AuthService>(context);
    final newRepository = Provider.of<RachaRepository>(context);

    if (_isInit || _currentUser != authService.user) {
      final previousUser = _currentUser;
      _currentUser = authService.user;
      _rachaRepository = newRepository;
      
      if (previousUser == null && _currentUser != null) {
        _handleUserDataMigration().then((_) {
          _loadInitialData();
        });
      } else {
        _loadInitialData();
      }
      
      if (_isInit) {
        _isInit = false;
      }
    }
  }

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

    if (mounted) {
      setState(() {
        _rachas = loadedRachas;
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
      MaterialPageRoute(
        builder: (context) => RachaDetailsScreen(
          racha: racha,
          repository: _rachaRepository,
        ),
      ),
    );

    if (result == 'delete') {
      await _rachaRepository.deleteRacha(racha.id);
      setState(() {
        _rachas.removeAt(index);
      });
    } else if (result is Racha) {
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
      const AmigosPage(),
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

class AmigosPage extends StatefulWidget {
  const AmigosPage({super.key});

  @override
  State<AmigosPage> createState() => _AmigosPageState();
}

class _AmigosPageState extends State<AmigosPage> {
  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = Provider.of<UserService>(context, listen: false);
  }

  void _confirmRemoveFriend(UserModel friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Amigo'),
        content: Text('Tem certeza que deseja remover ${friend.displayName} da sua lista de amigos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _userService.removeFriend(friend.uid);
              Navigator.of(context).pop();
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    if (authService.user == null) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: Text('Amigos', style: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w500)),
        ),
        body: const Center(
          child: Text('Faça login para ver e adicionar amigos.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text('Amigos', style: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w500)),
        actions: [
          StreamBuilder<List<UserModel>>(
            stream: _userService.getFriends(),
            builder: (context, friendsSnapshot) {
              return StreamBuilder<Set<String>>(
                stream: _userService.getSentRequestIds(),
                builder: (context, requestsSnapshot) {
                  if (!friendsSnapshot.hasData || !requestsSnapshot.hasData) {
                    return const IconButton(
                      icon: Icon(Icons.person_add_alt_1),
                      onPressed: null,
                    );
                  }
                  final friends = friendsSnapshot.data!;
                  final sentRequests = requestsSnapshot.data!;
                  final friendIds = friends.map((f) => f.uid).toSet();

                  return IconButton(
                    icon: const Icon(Icons.person_add_alt_1),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddFriendDialog(
                          friendIds: friendIds,
                          sentRequestIds: sentRequests,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFriendRequestsSection(),
          const SizedBox(height: 24),
          _buildFriendsListSection(),
        ],
      ),
    );
  }

  Widget _buildFriendRequestsSection() {
    return StreamBuilder<List<FriendRequestModel>>(
      stream: _userService.getFriendRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final requests = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PEDIDOS DE AMIZADE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ...requests.map((request) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(request.senderPhotoUrl),
                ),
                title: Text(request.senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _userService.acceptFriendRequest(request.senderId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _userService.declineFriendRequest(request.senderId),
                    ),
                  ],
                ),
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildFriendsListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MEUS AMIGOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        StreamBuilder<List<UserModel>>(
          stream: _userService.getFriends(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('Você ainda não tem amigos.')),
              );
            }
            final friends = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ColorHelper.getColorForName(friend.displayName),
                      backgroundImage: friend.photoURL.isNotEmpty ? NetworkImage(friend.photoURL) : null,
                      child: friend.photoURL.isEmpty 
                        ? Text(friend.displayName.isNotEmpty ? friend.displayName[0] : 'U', style: const TextStyle(color: Colors.white))
                        : null,
                    ),
                    title: Text(friend.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(friend.username ?? friend.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent),
                      onPressed: () => _confirmRemoveFriend(friend),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
