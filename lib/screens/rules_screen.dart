import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state_model.dart';
import '../providers/game_provider.dart';
import '../widgets/game_status_panel.dart';
import '../widgets/rule_option_tile.dart';
import '../widgets/home_navigation_button.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});
  static const categories = <String, String>{
    'Parole': 'Opens conversation and invites a player to speak or share.',
    'Mémoire': 'Prompts a personal or collective memory.',
    'Écoute': 'Prompts active listening before responding.',
    'Réponse': 'Invites a reply to another player or card.',
    'Sauvage': 'A flexible card that can change the active colour or category.',
  };
  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final state = game.state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rules'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: HomeNavigationButton(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'How to play',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Play a card that matches the active colour or category. A Sauvage card is always valid and selects what comes next. If you cannot play, draw according to the selected draw rule. The first player with an empty hand wins unless collaborative mode is enabled.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Example: a blue Mémoire card can follow another blue card or another Mémoire card when colour-or-category matching is active.',
          ),
          const SizedBox(height: 24),
          Text(
            'Card categories',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          ...categories.entries.map(
            (entry) =>
                ListTile(title: Text(entry.key), subtitle: Text(entry.value)),
          ),
          const SizedBox(height: 20),
          Text(
            'Live game state',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          if (state == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Start or continue a game to display the top card, active colour/category, direction, piles and current player.',
                ),
              ),
            )
          else
            GameStatusPanel(state: state),
          const SizedBox(height: 20),
          Text(
            'Optional variations',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (state == null)
            const Text('Options become editable during a game.')
          else ...[
            DropdownButtonFormField<DrawRule>(
              initialValue: state.drawRule,
              decoration: const InputDecoration(labelText: 'Draw rule'),
              items: const [
                DropdownMenuItem(
                  value: DrawRule.drawOneAndPass,
                  child: Text('Draw one and pass'),
                ),
                DropdownMenuItem(
                  value: DrawRule.drawUntilPlayable,
                  child: Text('Draw until playable'),
                ),
              ],
              onChanged: (value) {
                if (value != null) game.updateRules(drawRule: value);
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<MatchRule>(
              initialValue: state.matchRule,
              decoration: const InputDecoration(labelText: 'Matching rule'),
              items: const [
                DropdownMenuItem(
                  value: MatchRule.colourOnly,
                  child: Text('Match colour only'),
                ),
                DropdownMenuItem(
                  value: MatchRule.categoryOnly,
                  child: Text('Match category only'),
                ),
                DropdownMenuItem(
                  value: MatchRule.colourOrCategory,
                  child: Text('Match colour or category'),
                ),
              ],
              onChanged: (value) {
                if (value != null) game.updateRules(matchRule: value);
              },
            ),
            RuleOptionTile(
              title: 'Allow stacking draw cards',
              subtitle: 'Players may combine compatible draw effects.',
              value: state.allowStacking,
              onChanged: (v) => game.updateRules(stacking: v),
            ),
            RuleOptionTile(
              title: 'Timed turns',
              subtitle: 'Turns use a shared time limit.',
              value: state.timedTurns,
              onChanged: (v) => game.updateRules(timed: v),
            ),
            RuleOptionTile(
              title: 'Collaborative mode',
              subtitle: 'Play together without declaring a winner.',
              value: state.collaborativeMode,
              onChanged: (v) => game.updateRules(collaborative: v),
            ),
            RuleOptionTile(
              title: 'Conversation mode',
              subtitle: 'Every played card requires a response.',
              value: state.conversationMode,
              onChanged: (v) => game.updateRules(conversation: v),
            ),
            RuleOptionTile(
              title: 'Journal mode',
              subtitle: 'Responses are prepared for journal capture.',
              value: state.journalMode,
              onChanged: (v) => game.updateRules(journal: v),
            ),
          ],
        ],
      ),
    );
  }
}
