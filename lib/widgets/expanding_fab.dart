import 'package:flutter/material.dart';

/// Um objeto para definir uma ação dentro do menu FAB expansível.
///
/// Cada ação consiste em um ícone, um rótulo de texto e uma função
/// a ser executada quando o botão é pressionado.
@immutable
class FabAction {
  const FabAction({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
}

/// Um widget de menu Floating Action Button (FAB) que se expande para revelar
/// um conjunto de ações secundárias.
///
/// Este widget é stateful e gerencia suas próprias animações para abrir e fechar.
class ExpandingFab extends StatefulWidget {
  const ExpandingFab({
    super.key,
    required this.actions,
  });

  final List<FabAction> actions;

  @override
  State<ExpandingFab> createState() => _ExpandingFabState();
}

class _ExpandingFabState extends State<ExpandingFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    // Animação com uma curva suave para a expansão e retração.
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Alterna o estado do menu (aberto/fechado) e dispara a animação.
  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // *** ALTERAÇÃO PRINCIPAL: USA SIZETRANSITION ***
        // Isso garante que a coluna de ações tenha tamanho zero quando fechada,
        // evitando problemas de overflow no layout pai.
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _buildExpandingActionButtons(),
          ),
        ),
        FloatingActionButton(
          onPressed: _toggle,
          heroTag: 'menu_fab',
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _expandAnimation,
          ),
        ),
      ],
    );
  }

  /// Constrói a lista de botões de ação que aparecem quando o menu está aberto.
  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.actions.length;

    for (var i = 0; i < count; i++) {
      children.add(
        _ActionFabWithLabel(
          action: widget.actions[i],
          onPressed: () {
            // Executa a ação e fecha o menu.
            widget.actions[i].onPressed();
            _toggle();
          },
        ),
      );
    }
    // Inverte a lista para que a primeira ação apareça mais perto do FAB.
    return children.reversed.toList();
  }
}

/// Um widget interno que combina um FAB pequeno com um rótulo de texto.
class _ActionFabWithLabel extends StatelessWidget {
  const _ActionFabWithLabel({
    required this.action,
    required this.onPressed,
  });

  final FabAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Rótulo do botão
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(action.label, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(width: 12.0),
          // Botão de ação (FAB pequeno)
          FloatingActionButton.small(
            heroTag: null,
            onPressed: onPressed,
            backgroundColor: action.backgroundColor ?? theme.colorScheme.secondaryContainer,
            foregroundColor: action.foregroundColor ?? theme.colorScheme.onSecondaryContainer,
            child: Icon(action.icon),
          ),
        ],
      ),
    );
  }
}
