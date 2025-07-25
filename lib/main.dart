import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa o pacote de fontes do Google
import 'widgets/racha_card.dart';
import 'screens/create_racha_screen.dart';
import 'screens/racha_details_screen.dart';
import 'models/racha_model.dart';
import 'models/expense_model.dart';
import 'services/storage_service.dart';
import 'utils/color_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bora Rachar?',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF415F91),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFD6E3FF),
          onPrimaryContainer: Color(0xFF001B3E),
          secondary: Color(0xFF565F71),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFDAE2F9),
          onSecondaryContainer: Color(0xFF131C2B),
          tertiary: Color(0xFF705575),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFFFAD8FD),
          onTertiaryContainer: Color(0xFF28132E),
          error: Color(0xFFBA1A1A),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF410002),
          background: Color(0xFFF9F9FF),
          onBackground: Color(0xFF191C20),
          surface: Color(0xFFF9F9FF),
          onSurface: Color(0xFF191C20),
          surfaceVariant: Color(0xFFE0E2EC),
          onSurfaceVariant: Color(0xFF44474E),
          outline: Color(0xFF74777F),
          shadow: Color(0xFF000000),
          inverseSurface: Color(0xFF2E3036),
          onInverseSurface: Color(0xFFF0F0F7),
          inversePrimary: Color(0xFFAAC7FF),
          surfaceTint: Color(0xFF415F91),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F9FF),
        // **FONTE ALTERADA PARA ROBOTO**
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        cardTheme: CardThemeData(
          elevation: 1,
          color: const Color(0xFFFFFFFF),
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF415F91),
            foregroundColor: const Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9F9FF),
          elevation: 0,
          scrolledUnderElevation: 0,
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
    var loadedRachas = await _storageService.loadRachas();
    final loadedUserName = await _storageService.loadUserName();
    
    if (loadedRachas.isEmpty) {
      loadedRachas = _getMockRachas();
      await _storageService.saveRachas(loadedRachas);
    }

    setState(() {
      _rachas = loadedRachas;
      _userName = loadedUserName;
      _isLoading = false;
    });
  }

  Future<void> _saveRachasToStorage() async {
    await _storageService.saveRachas(_rachas);
  }

  Future<void> _saveUserName(String newName) async {
    final oldName = _userName;
    final updatedRachas = _rachas.map((racha) {
      final updatedParticipants = racha.participants.map((p) => p == oldName ? newName : p).toList();
      final updatedExpenses = racha.expenses.map((expense) {
        final updatedSharedWith = expense.sharedWith.map((p) => p == oldName ? newName : p).toList();
        final updatedPaidBy = expense.paidBy == oldName ? newName : expense.paidBy;
        return Expense(
          description: expense.description,
          amount: expense.amount,
          sharedWith: updatedSharedWith,
          paidBy: updatedPaidBy,
          countsForSettlement: expense.countsForSettlement,
        );
      }).toList();
      return Racha(
        title: racha.title,
        date: racha.date,
        participants: updatedParticipants,
        expenses: updatedExpenses,
        isFinished: racha.isFinished,
        serviceFeeValue: racha.serviceFeeValue,
        serviceFeeType: racha.serviceFeeType,
        serviceFeeParticipants: racha.serviceFeeParticipants.map((p) => p == oldName ? newName : p).toList(),
      );
    }).toList();

    setState(() {
      _userName = newName;
      _rachas = updatedRachas;
    });
    await _storageService.saveUserName(newName);
    await _saveRachasToStorage();
  }

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
      PerfilPage(
        userName: _userName,
        onSaveName: _saveUserName,
      ),
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

  List<Racha> _getMockRachas() {
    return [
      Racha(
        title: 'Jantar de Aniversário',
        date: 'Hoje',
        participants: ['Você', 'Jeff', 'Nubya', 'Frans', 'Kayky'],
        expenses: [
          Expense(description: 'Rodízio de Pizza', amount: 350.0, sharedWith: ['Você', 'Jeff', 'Nubya', 'Frans', 'Kayky'], paidBy: 'Jeff'),
          Expense(description: 'Bebidas', amount: 120.0, sharedWith: ['Você', 'Jeff', 'Nubya', 'Frans', 'Kayky']),
          Expense(description: 'Sobremesa Especial', amount: 35.0, sharedWith: ['Nubya']),
        ],
      ),
      Racha(
        title: 'Happy Hour da Firma',
        date: 'Ontem',
        participants: ['Você', 'Michele', 'Amanda', 'Kah', 'Jeff'],
        expenses: [
          Expense(description: 'Porções', amount: 180.0, sharedWith: ['Você', 'Michele', 'Amanda', 'Kah', 'Jeff']),
          Expense(description: 'Chopp', amount: 250.0, sharedWith: ['Você', 'Michele', 'Amanda', 'Kah', 'Jeff'], paidBy: 'Michele'),
        ],
      ),
      Racha(
        title: 'Cinema',
        date: 'Mês Passado',
        participants: ['Você', 'Jeff', 'Frans'],
        isFinished: true,
        expenses: [
          Expense(description: 'Ingressos', amount: 90.0, sharedWith: ['Você', 'Jeff', 'Frans']),
          Expense(description: 'Pipoca', amount: 45.0, sharedWith: ['Você', 'Jeff']),
        ],
      ),
    ];
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
        // **FONTE DO TÍTULO ATUALIZADA**
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

class PerfilPage extends StatefulWidget {
  final String userName;
  final Function(String) onSaveName;

  const PerfilPage({
    super.key,
    required this.userName,
    required this.onSaveName,
  });

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text('Perfil', style: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w500)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: ColorHelper.getColorForName(widget.userName),
                child: Text(
                  widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 40),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
              const Text('voce@email.com', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.onSaveName(_nameController.text);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nome salvo com sucesso!')),
              );
            },
            child: const Text('Salvar Nome'),
          ),
          const SizedBox(height: 30),
          const Text('CONFIGURAÇÕES', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Modo Escuro'),
                  trailing: Switch(value: false, onChanged: (val) {}),
                ),
                ListTile(
                  leading: const Icon(Icons.pix),
                  title: const Text('Minha Chave PIX'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Sair', style: TextStyle(color: Colors.red)),
                  onTap: () {},
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
