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
    const maxAvatars = 5;
    final itemsToShow = racha.participants.length > maxAvatars ? maxAvatars : racha.participants.length;

    if (itemsToShow == 0) {
      return const SizedBox(height: 32);
    }

    return SizedBox(
      height: 32,
      child: Stack(
        children: List.generate(
          itemsToShow,
          (index) {
            // --- MUDANÇA AQUI ---
            final participant = racha.participants[index];
            final name = participant.displayName;
            final photoURL = participant.photoURL;

            if (index == maxAvatars - 1 && racha.participants.length > maxAvatars) {
              return Positioned(
                left: (index * 24).toDouble(),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Text('+${racha.participants.length - (maxAvatars - 1)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              );
            }
            
            return Positioned(
              left: (index * 24).toDouble(),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: ColorHelper.getColorForName(name),
                backgroundImage: (photoURL != null && photoURL.isNotEmpty) ? NetworkImage(photoURL) : null,
                child: (photoURL == null || photoURL.isEmpty)
                  ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))
                  : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
