import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Importações de telas e serviços
import 'profile_page.dart';
import 'create_racha_screen.dart';
import 'racha_details_screen.dart';
import 'rachas_page.dart';
import 'friends_page.dart';

import '../models/racha_model.dart';
import '../models/user_model.dart';
import '../repositories/racha_repository.dart';
import '../repositories/local_storage_repository.dart';
import '../repositories/firestore_repository.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/add_friend_dialog.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Lógica de estado que estava em MainScreenState
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
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            content: const Text(
                'Encontramos rachas salvos no seu aparelho. Deseja movê-los para sua conta na nuvem?'),
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
      _loadInitialData();
    } else if (result is Racha) {
      _loadInitialData();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 170.0;
    const double navBarHeight = 107.0;
    const double extraTopPadding = 32.0;

    final List<Widget> pages = [
      RachasPage(
        rachas: _rachas,
        onRachaTap: _navigateToRachaDetails,
        isLoading: _isLoading,
        topPadding: headerHeight + extraTopPadding,
        bottomPadding: navBarHeight,
      ),
      FriendsPage(
        topPadding: headerHeight + extraTopPadding,
        bottomPadding: navBarHeight,
      ),
      PerfilPage(
        topPadding: headerHeight + extraTopPadding,
        bottomPadding: navBarHeight,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: pages,
          ),
          _buildFloatingHeader(headerHeight),
          _buildCustomNavBar(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateAndCreateRacha,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFloatingHeader(double height) {
    const List<String> titles = ['Meus Rachas', 'Amigos', 'Perfil'];
    const Color headerColor = Color(0xFF222531);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: height,
        padding: EdgeInsets.only(
          left: 24,
          right: 16,
          top: MediaQuery.of(context).padding.top + 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.1, 0.7, 1.0], // 10%, 70%, 100%
            colors: [
              headerColor.withOpacity(1.0),   // 100%
              headerColor.withOpacity(0.95),  // 95%
              headerColor.withOpacity(0.80),  // 80%
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              titles[_selectedIndex],
              style: Theme.of(context).textTheme.displayLarge,
            ),
            if (_selectedIndex == 0)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: IconButton(
                  icon: const Icon(Icons.search, size: 30),
                  onPressed: () {
                    // TODO: Implementar lógica de busca
                  },
                ),
              ),
            if (_selectedIndex == 1) _buildAddFriendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFriendButton() {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.user == null) {
      return const SizedBox.shrink();
    }

    final userService = Provider.of<UserService>(context, listen: false);
    return StreamBuilder<List<UserModel>>(
      stream: userService.getFriends(),
      builder: (context, friendsSnapshot) {
        return StreamBuilder<Set<String>>(
          stream: userService.getSentRequestIds(),
          builder: (context, requestsSnapshot) {
            if (!friendsSnapshot.hasData || !requestsSnapshot.hasData) {
              return const IconButton(icon: Icon(Icons.person_add_alt_1), onPressed: null);
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
    );
  }

  Widget _buildCustomNavBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Dimensões proporcionais baseadas na tela de referência
    final scaleFactor = screenWidth / 448; // 1344px / 3 (densidade de pixel ~3x)

    final double navBarWidth = 347.96 * scaleFactor;
    final double navBarHeight = 87.0 * scaleFactor;
    final double navBarRadius = 54.37 * scaleFactor;

    final double highlightWidth = 147.88 * scaleFactor;
    final double highlightHeight = 54.37 * scaleFactor;
    
    final positions = _calculateItemPositions(navBarWidth, highlightWidth);

    return Positioned(
      bottom: 20,
      left: (screenWidth - navBarWidth) / 2,
      right: (screenWidth - navBarWidth) / 2,
      child: Container(
        width: navBarWidth,
        height: navBarHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(navBarRadius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5],
            colors: [
              AppTheme.darkNavBar.withOpacity(0.95),
              AppTheme.darkNavBar.withOpacity(0.90),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Bolha de destaque animada
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: (navBarHeight - highlightHeight) / 2,
              left: positions['highlight'],
              child: Container(
                width: highlightWidth,
                height: highlightHeight,
                decoration: BoxDecoration(
                  color: AppTheme.darkSelectedNavItemBg,
                  borderRadius: BorderRadius.circular(navBarRadius),
                ),
              ),
            ),
            // Itens da Navbar
            _navBarItem(Icons.home, 'RACHAS', 0, positions[0]!, highlightWidth),
            _navBarItem(Icons.people_outline, 'AMIGOS', 1, positions[1]!, highlightWidth),
            _navBarItem(Icons.person_outline, 'PERFIL', 2, positions[2]!, highlightWidth),
          ],
        ),
      ),
    );
  }

  Map<dynamic, double> _calculateItemPositions(double navBarWidth, double highlightWidth) {
    // Dimensões baseadas em pixels lógicos
    const double edgePadding = 26.0;
    const double unselectedIconWidth = 48.0;

    double pos0, pos1, pos2, highlightPos;

    switch (_selectedIndex) {
      case 0: // Home selecionado
        highlightPos = edgePadding;
        pos0 = edgePadding;
        // Calcula o espaço restante à direita da bolha
        final remainingSpace = navBarWidth - highlightWidth - edgePadding;
        // Divide o espaço restante em 3 partes para espaçar os 2 ícones uniformemente
        final spacing = (remainingSpace - (unselectedIconWidth * 2)) / 3;
        pos1 = highlightPos + highlightWidth + spacing;
        pos2 = pos1 + unselectedIconWidth + spacing;
        break;
      case 1: // Amigos (central) selecionado
        final double slotWidth = navBarWidth / 3;
        highlightPos = (navBarWidth / 2) - (highlightWidth / 2);
        pos0 = (slotWidth / 2) - (unselectedIconWidth / 2);
        pos1 = highlightPos;
        pos2 = navBarWidth - slotWidth + (slotWidth / 2) - (unselectedIconWidth / 2);
        break;
      case 2: // Perfil selecionado
      default:
        highlightPos = navBarWidth - highlightWidth - edgePadding;
        pos2 = highlightPos;
        // Calcula o espaço restante à esquerda da bolha
        final remainingSpace = navBarWidth - highlightWidth - edgePadding;
        // Divide o espaço restante em 3 partes para espaçar os 2 ícones uniformemente
        final spacing = (remainingSpace - (unselectedIconWidth * 2)) / 3;
        pos0 = edgePadding + spacing;
        pos1 = pos0 + unselectedIconWidth + spacing;
        break;
    }
    return {0: pos0, 1: pos1, 2: pos2, 'highlight': highlightPos};
  }

  Widget _navBarItem(IconData icon, String label, int index, double leftPosition, double highlightWidth) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppTheme.darkSelectedNavItemFg : AppTheme.darkUnselectedNavItemFg;
    final itemWidth = isSelected ? highlightWidth : 48.0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: leftPosition,
      top: 0,
      bottom: 0,
      width: itemWidth,
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Padding(
                padding: EdgeInsets.only(left: isSelected ? 8.0 : 0.0),
                child: Text(
                  isSelected ? label : '',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
