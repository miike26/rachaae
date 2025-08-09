import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

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
  final ScrollController _scrollController = ScrollController();

  // Lógica de estado que estava em MainScreenState
  List<Racha> _rachas = [];
  late RachaRepository _rachaRepository;
  User? _currentUser;
  bool _isInit = true;
  bool _isLoading = true;
  bool _isFabPressed = false;

  // NOVO: Estado para controlar a opacidade do cabeçalho
  double _headerOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // NOVO: Listener de scroll para animar o cabeçalho
  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      // A animação começa após rolar 50 pixels e vai até 150 pixels
      final newOpacity = ((offset - 50) / 100).clamp(0.0, 1.0);
      if (newOpacity != _headerOpacity) {
        setState(() {
          _headerOpacity = newOpacity;
        });
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
    const double headerHeight = 150.0;
    const double navBarBottomOffset = 27.0;
    const double extraTopPadding = 13.0;

    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 448;
    final double navBarHeight = 87.0 * scaleFactor;
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    final List<Widget> pages = [
      RachasPage(
        rachas: _rachas,
        onRachaTap: _navigateToRachaDetails,
        isLoading: _isLoading,
        topPadding: headerHeight + extraTopPadding,
        bottomPadding: navBarHeight + navBarBottomOffset,
        scrollController: _scrollController, // Passa o controller para a página
      ),
      FriendsPage(
        topPadding: headerHeight + extraTopPadding,
        bottomPadding: navBarHeight + navBarBottomOffset,
      ),
      PerfilPage(
        topPadding: headerHeight + extraTopPadding,
        bottomPadding: navBarHeight + navBarBottomOffset,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // NOVO: Background SVG para o tema claro
          if (isLightTheme) _buildBackgroundVector(),
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
          _buildCustomNavBar(navBarHeight, navBarBottomOffset, scaleFactor),
          Positioned(
            bottom: navBarBottomOffset + 110.0,
            right: 17.0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: _selectedIndex == 0
                  ? _buildCreateRachaButton(navBarHeight)
                  : const SizedBox.shrink(key: ValueKey('emptyFab')),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para o SVG de fundo com a correção
  Widget _buildBackgroundVector() {
    // --- CONTROLES DO SVG ---
    final double posX = -0.2; // -1.0 (esquerda) a 1.0 (direita)
    final double posY = -0.20; // -1.0 (topo) a 1.0 (base)
    final double scale = 1.5; // Fator de zoom
    final double blur = 3250.0; // Intensidade do desfoque
    final double opacity = 0.15; // Opacidade geral
    // -------------------------

    return Positioned.fill(
      child: ClipRect(
        child: Transform.scale(
          scale: scale,
          alignment: Alignment(posX, posY),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Opacity( // Usa o widget Opacity para não afetar as cores
              opacity: opacity,
              child: SvgPicture.asset(
                'assets/images/background_vector.svg',
                fit: BoxFit.cover,
                // colorFilter foi removido para usar as cores originais do SVG
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHeader(double height) {
    const List<String> titles = ['Meus Rachas', 'Amigos', 'Perfil'];
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color headerColor = isLightTheme ? AppTheme.lightHeaderBg : AppTheme.darkHeaderBg;

    // Define os stops do gradiente com base no tema e na opacidade do scroll
    final List<Color> colors;
    if (isLightTheme) {
      colors = [
        headerColor.withOpacity(1.0 * _headerOpacity),
        headerColor.withOpacity(0.95 * _headerOpacity),
        headerColor.withOpacity(0.80 * _headerOpacity),
        headerColor.withOpacity(0.0 * _headerOpacity),
      ];
    } else {
      colors = [
        headerColor.withOpacity(1.0),
        headerColor.withOpacity(0.95),
        headerColor.withOpacity(0.80),
      ];
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: height,
        padding: EdgeInsets.only(
          left: 24,
          right: 16,
          top: MediaQuery.of(context).padding.top, // Usa a área segura
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: isLightTheme ? const [0.1, 0.5, 0.75, 1.0] : const [0.1, 0.7, 1.0],
            colors: colors,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 22.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  titles[_selectedIndex],
                  style: isLightTheme
                      ? Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.lightTextColor)
                      : Theme.of(context).textTheme.displayLarge,
                ),
              ),
              if (_selectedIndex == 0)
                IconButton(
                  icon: const Icon(Icons.search, size: 30),
                  onPressed: () {},
                ),
              if (_selectedIndex == 1) 
                _buildAddFriendButton(),
            ],
          ),
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

  Widget _buildCustomNavBar(double navBarHeight, double navBarBottomOffset, double scaleFactor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final authService = Provider.of<AuthService>(context, listen: false);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    
    final double navBarWidth = 347.96 * scaleFactor;
    final double navBarRadius = 54.37 * scaleFactor;
    final double highlightWidth = 147.88 * scaleFactor;
    final double highlightHeight = 54.37 * scaleFactor;
    
    final positions = _calculateItemPositions(navBarWidth, highlightWidth);

    return Positioned(
      bottom: navBarBottomOffset,
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
            stops: isLightTheme ? const [0.0, 0.5] : const [0.0, 0.5],
            colors: isLightTheme
                ? [ AppTheme.lightNavBar.withOpacity(0.95), AppTheme.lightNavBar.withOpacity(0.90) ]
                : [ AppTheme.darkNavBar.withOpacity(0.98), AppTheme.darkNavBar.withOpacity(0.92) ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 48.93,
              offset: const Offset(0, 16.31),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: (navBarHeight - highlightHeight) / 2,
              left: positions['highlight'],
              child: Container(
                width: highlightWidth,
                height: highlightHeight,
                decoration: BoxDecoration(
                  color: isLightTheme ? AppTheme.lightSelectedNavItemBg : AppTheme.darkSelectedNavItemBg,
                  borderRadius: BorderRadius.circular(navBarRadius),
                ),
              ),
            ),
            _navBarItem(Icons.home, 'RACHAS', 0, positions[0]!, highlightWidth),
            _navBarItem(Icons.people_alt, 'AMIGOS', 1, positions[1]!, highlightWidth),
            _navBarItem(Icons.person_outline, 'PERFIL', 2, positions[2]!, highlightWidth, authService: authService),
          ],
        ),
      ),
    );
  }

  Map<dynamic, double> _calculateItemPositions(double navBarWidth, double highlightWidth) {
    const double edgePadding = 26.0;
    const double unselectedIconWidth = 48.0;
    double pos0, pos1, pos2, highlightPos;
    final double contentWidth = navBarWidth - (2 * edgePadding);
    final double totalItemWidth = (2 * unselectedIconWidth) + highlightWidth;
    final double spacing = (contentWidth - totalItemWidth) / 2.0;

    switch (_selectedIndex) {
      case 0:
        highlightPos = edgePadding;
        pos0 = edgePadding;
        pos1 = highlightPos + highlightWidth + spacing;
        pos2 = pos1 + unselectedIconWidth + spacing;
        break;
      case 1:
        pos0 = edgePadding;
        highlightPos = pos0 + unselectedIconWidth + spacing;
        pos1 = highlightPos;
        pos2 = highlightPos + highlightWidth + spacing;
        break;
      case 2:
      default:
        pos0 = edgePadding;
        pos1 = pos0 + unselectedIconWidth + spacing;
        highlightPos = pos1 + unselectedIconWidth + spacing;
        pos2 = highlightPos;
        break;
    }
    return {0: pos0, 1: pos1, 2: pos2, 'highlight': highlightPos};
  }

  Widget _navBarItem(IconData icon, String label, int index, double leftPosition, double highlightWidth, {AuthService? authService}) {
    final isSelected = _selectedIndex == index;
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final color = isSelected
        ? (isLightTheme ? AppTheme.lightSelectedNavItemFg : AppTheme.darkSelectedNavItemFg)
        : (isLightTheme ? AppTheme.lightUnselectedNavItemFg : AppTheme.darkUnselectedNavItemFg);
    final itemWidth = isSelected ? highlightWidth : 48.0;
    const double iconSize = 30.0;
    Widget iconWidget;
    final user = authService?.user;

    if (index == 2 && user?.photoURL != null) {
      iconWidget = CircleAvatar(
        radius: iconSize / 2.0,
        backgroundColor: isLightTheme ? AppTheme.lightUnselectedNavItemFg : Colors.white,
        child: CircleAvatar(
          radius: (iconSize / 2) - 1.5,
          backgroundImage: NetworkImage(user!.photoURL!),
        ),
      );
    } else {
      iconWidget = Icon(icon, color: color, size: iconSize);
    }

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
            iconWidget,
            Flexible(
              child: AnimatedSize(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRachaButton(double navBarHeight) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      key: const ValueKey('createRachaButton'),
      onTap: _navigateAndCreateRacha,
      onTapDown: (_) => setState(() => _isFabPressed = true),
      onTapUp: (_) => setState(() => _isFabPressed = false),
      onTapCancel: () => setState(() => _isFabPressed = false),
      child: AnimatedScale(
        scale: _isFabPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 75,
          width: 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: isLightTheme ? const [0.0, 1.0] : const [0.0, 1.0],
              colors: isLightTheme
                  ? [ AppTheme.lightFab.withOpacity(0.90), AppTheme.lightFab.withOpacity(1.0) ]
                  : [ AppTheme.darkFab1.withOpacity(0.90), AppTheme.darkFab2.withOpacity(1.00) ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.add_outlined,
            size: 30.0,
            color: isLightTheme ? AppTheme.lightFabIcon : AppTheme.darkFabIcon,
          ),
        ),
      ),
    );
  }
}
