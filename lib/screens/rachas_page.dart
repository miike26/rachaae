import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/racha_model.dart';
import '../widgets/racha_card.dart';

class RachasPage extends StatelessWidget {
  final List<Racha> rachas;
  final Function(Racha, int) onRachaTap;
  final bool isLoading;
  final double topPadding;
  final double bottomPadding;

  const RachasPage({
    super.key,
    required this.rachas,
    required this.onRachaTap,
    required this.isLoading,
    required this.topPadding,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final openRachas = rachas.where((r) => !r.isFinished).toList();
    final finishedRachas = rachas.where((r) => r.isFinished).toList();

    if (rachas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Text(
            'Crie seu primeiro racha!',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16.0, topPadding, 16.0, bottomPadding),
      children: [
        if (openRachas.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text('EM ABERTO',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
            child: Text('FINALIZADOS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
    );
  }
}
