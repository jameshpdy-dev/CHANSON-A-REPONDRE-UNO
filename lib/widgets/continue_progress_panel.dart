import 'package:flutter/material.dart';
import '../models/deck_model.dart';
import '../models/game_state_model.dart';
import '../theme/app_theme.dart';
import 'continue_panel.dart';

class ContinueProgressPanel extends StatelessWidget {
  const ContinueProgressPanel({
    required this.deck,
    required this.game,
    required this.onContinue,
    super.key,
  });
  final Deck? deck;
  final GameStateModel? game;
  final VoidCallback onContinue;
  @override
  Widget build(BuildContext context) {
    if (deck != null && game != null) {
      return ContinuePanel(deck: deck!, game: game, onContinue: onContinue);
    }
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xD912110E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gold),
      ),
      child: Row(
        children: [
          const Icon(Icons.save_outlined, color: AppTheme.gold, size: 36),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CONTINUER OÙ VOUS EN ÉTIEZ'),
                SizedBox(height: 3),
                Text('Aucune partie enregistrée'),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.play_arrow),
            label: const Text('COMMENCER'),
          ),
        ],
      ),
    );
  }
}
