import 'package:flutter/material.dart';
import '../models/racha_model.dart';
import '../utils/color_helper.dart';

class RachaCard extends StatelessWidget {
  final Racha racha;
  final VoidCallback onTap;

  const RachaCard({
    super.key,
    required this.racha,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos o Card diretamente, pois o tema já define o estilo.
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                racha.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    racha.date,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  Text(
                    'R\$ ${racha.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildParticipantAvatars(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantAvatars() {
    final initials = racha.participants.map((name) => name.isNotEmpty ? name[0].toUpperCase() : '?').toList();

    const maxAvatars = 5;
    final itemsToShow = initials.length > maxAvatars ? maxAvatars : initials.length;

    return SizedBox(
      height: 32,
      child: Stack(
        children: List.generate(
          itemsToShow,
          (index) {
            final name = racha.participants[index];
            final initial = initials[index];
            
            if (index == maxAvatars - 1 && initials.length > maxAvatars) {
              return Positioned(
                left: (index * 24).toDouble(),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Text('+${initials.length - (maxAvatars - 1)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              );
            }
            return Positioned(
              left: (index * 24).toDouble(),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: ColorHelper.getColorForName(name),
                child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            );
          },
        ),
      ),
    );
  }
}
