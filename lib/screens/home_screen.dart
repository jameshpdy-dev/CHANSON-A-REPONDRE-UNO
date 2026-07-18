import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/chanson_a_repondre_uno_deck.dart';
import '../models/card_item.dart';
import '../providers/cards_provider.dart';

/// Restored approved dashboard interface for CHANSON À RÉPONDRE UNO.
class HomeScreen extends StatelessWidget {
  /// Creates the application home screen.
  const HomeScreen({super.key});

  static const _gold = Color(0xFFE3A82E);
  static const _cream = Color(0xFFF1E3C5);
  static const _ink = Color(0xFF070605);
  static const _panel = Color(0xD9110F0B);

  static const _menuItems = <_HomeAction>[
    _HomeAction(
      title: 'PLAY',
      subtitle: 'Jouer une nouvelle\npartie ou continuer\nune partie existante.',
      icon: Icons.play_arrow_rounded,
      route: '/play',
      accent: Color(0xFFE43C2C),
      semanticsLabel: 'Play',
    ),
    _HomeAction(
      title: 'CHOISIR UN DECK',
      subtitle: 'Sélectionner, créer ou\ngérer vos decks de\ncartes.',
      icon: Icons.style_rounded,
      route: '/decks',
      accent: Color(0xFFE7B330),
      semanticsLabel: 'Choose Deck',
    ),
    _HomeAction(
      title: 'PARCOURIR LES CARTES',
      subtitle: 'Explorer toutes les\ncartes par deck\nou catégorie.',
      icon: Icons.menu_book_rounded,
      route: '/cards',
      accent: Color(0xFF74B842),
      semanticsLabel: 'Browse Cards',
    ),
    _HomeAction(
      title: 'RECHERCHER',
      subtitle: 'Trouver des cartes par\nmot-clé, thème, auteur\net plus encore.',
      icon: Icons.search_rounded,
      route: '/search',
      accent: Color(0xFF2EA4DC),
      semanticsLabel: 'Search',
    ),
    _HomeAction(
      title: 'JOURNAL',
      subtitle: 'Consulter vos entrées,\nnotes et souvenirs\nenregistrés.',
      icon: Icons.auto_stories_rounded,
      route: '/journal',
      accent: Color(0xFFB04FDB),
      semanticsLabel: 'Journal',
    ),
    _HomeAction(
      title: 'CHAT IA',
      subtitle: 'Discuter avec l’IA à\npropos des cartes\net de vos idées.',
      icon: Icons.smart_toy_rounded,
      route: '/ai-chat',
      accent: Color(0xFF35C9C5),
      semanticsLabel: 'AI Chat',
    ),
    _HomeAction(
      title: 'RÈGLES',
      subtitle: 'Apprendre les règles\ndu jeu et découvrir\ndes variantes.',
      icon: Icons.gavel_rounded,
      route: '/rules',
      accent: Color(0xFFE87524),
      semanticsLabel: 'Rules',
    ),
    _HomeAction(
      title: 'PARAMÈTRES',
      subtitle: 'Personnaliser votre\nexpérience de jeu et\nvos préférences.',
      icon: Icons.settings_rounded,
      route: '/settings',
      accent: Color(0xFFC8B79B),
      semanticsLabel: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<CardsProvider>().cards;
    final permanentCards = cards
        .where((card) => card.deckId == chansonARepondreUnoDeckId)
        .toList();
    final recentCards = permanentCards.take(6).toList();

    return Scaffold(
      backgroundColor: _ink,
      body: Stack(
        children: [
          Positioned.fill(child: _AtmosphericBackdrop(cards: permanentCards)),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final horizontal = width >= 900 ? 30.0 : 18.0;
                final columns = width >= 980
                    ? 4
                    : width >= 680
                    ? 3
                    : 2;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 104),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeroHeader(
                            onProfile: () => context.go('/profile'),
                            onSettings: () => context.go('/settings'),
                          ),
                          const SizedBox(height: 22),
                          GridView.builder(
                            itemCount: _menuItems.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
                                  childAspectRatio: width >= 980 ? 1.05 : .94,
                                ),
                            itemBuilder: (context, index) {
                              final item = _menuItems[index];
                              return _MenuTile(
                                action: item,
                                onTap: () => context.go(item.route),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          const _ContinuePanel(),
                          const SizedBox(height: 20),
                          _SectionHeader(
                            title: 'DECKS EN VEDETTE',
                            onViewAll: () => context.go('/decks'),
                          ),
                          const SizedBox(height: 12),
                          _FeaturedDecks(
                            permanentCount: permanentCards.length,
                          ),
                          const SizedBox(height: 20),
                          _SectionHeader(
                            title: 'CARTES RÉCENTES',
                            onViewAll: () => context.go('/cards'),
                          ),
                          const SizedBox(height: 12),
                          _RecentCards(cards: recentCards),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNavigation(),
    );
  }
}

class _AtmosphericBackdrop extends StatelessWidget {
  const _AtmosphericBackdrop({required this.cards});

  final List<CardItem> cards;

  @override
  Widget build(BuildContext context) {
    final previewCards = cards.take(4).toList();
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [Color(0xFF241306), Color(0xFF060504), Color(0xFF000000)],
        ),
      ),
      child: Stack(
        children: [
          for (var i = 0; i < previewCards.length; i++)
            Positioned(
              top: i.isEven ? -24 : 14,
              left: i < 2 ? 34.0 + (i * 90) : null,
              right: i >= 2 ? 34.0 + ((i - 2) * 90) : null,
              child: Transform.rotate(
                angle: (i - 1.5) * .16,
                child: Opacity(
                  opacity: .18,
                  child: SizedBox(
                    width: 150,
                    child: _CardImage(card: previewCards[i]),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(80),
                    Colors.black.withAlpha(8),
                    Colors.black.withAlpha(210),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.onProfile, required this.onSettings});

  final VoidCallback onProfile;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _RoundIconButton(
              icon: Icons.person_rounded,
              label: 'Profile',
              onTap: onProfile,
            ),
            _RoundIconButton(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: onSettings,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 66),
          child: Column(
            children: [
              const _RibbonText('CHANSON À RÉPONDRE'),
              Text(
                'UNO!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: .86,
                  fontSize: _responsiveTitleSize(context),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  color: const Color(0xFFE23B28),
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(6, 7),
                      blurRadius: 0,
                    ),
                    Shadow(color: Color(0xFFE9BE45), blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'L’ART DE LA PAROLE PARTAGÉE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HomeScreen._gold,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Text('♥', style: TextStyle(color: Color(0xFFC9291E))),
            ],
          ),
        ),
      ],
    );
  }

  double _responsiveTitleSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return math.max(70, math.min(150, width * .16));
  }
}

class _RibbonText extends StatelessWidget {
  const _RibbonText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF8E2318),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF3E110D), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black87, offset: Offset(0, 6), blurRadius: 10),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFF7D77A),
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: .7,
        ),
      ),
    );
  }
}

class _MenuTile extends StatefulWidget {
  const _MenuTile({required this.action, required this.onTap});

  final _HomeAction action;
  final VoidCallback onTap;

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    return Semantics(
      button: true,
      label: action.semanticsLabel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: HomeScreen._panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: HomeScreen._gold, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: action.accent.withAlpha(_hovered ? 95 : 35),
                  blurRadius: _hovered ? 22 : 10,
                  spreadRadius: _hovered ? 1 : 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, color: action.accent, size: 68),
                const SizedBox(height: 18),
                Text(
                  action.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: action.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  action.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: HomeScreen._cream,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinuePanel extends StatelessWidget {
  const _ContinuePanel();

  @override
  Widget build(BuildContext context) {
    return _GoldPanel(
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Transform.rotate(
              angle: -.13,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E471D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HomeScreen._cream, width: 2),
                ),
                child: const Text(
                  'ÉCOUTE',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: HomeScreen._cream),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONTINUER OÙ VOUS EN ÉTIEZ',
                  style: TextStyle(
                    color: HomeScreen._gold,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Julien Green',
                  style: TextStyle(
                    color: HomeScreen._cream,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '32 / 80 cartes explorées',
                  style: TextStyle(color: Color(0xFF83D345), fontSize: 20),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: .4,
                  minHeight: 10,
                  backgroundColor: Color(0xFF2B2B25),
                  color: Color(0xFF74B842),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          OutlinedButton(
            onPressed: () => context.go('/play'),
            style: OutlinedButton.styleFrom(
              foregroundColor: HomeScreen._gold,
              side: const BorderSide(color: HomeScreen._gold),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: const Text('CONTINUER'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: HomeScreen._gold,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Divider(color: HomeScreen._gold)),
        TextButton.icon(
          onPressed: onViewAll,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('VOIR TOUT'),
          style: TextButton.styleFrom(foregroundColor: HomeScreen._gold),
        ),
      ],
    );
  }
}

class _FeaturedDecks extends StatelessWidget {
  const _FeaturedDecks({required this.permanentCount});

  final int permanentCount;

  @override
  Widget build(BuildContext context) {
    final featured = <_FeaturedDeck>[
      _FeaturedDeck(
        'CHANSON À RÉPONDRE UNO',
        '$permanentCount cartes',
        Icons.style_rounded,
      ),
      const _FeaturedDeck('Julien Green', '80 cartes', Icons.person_rounded),
      const _FeaturedDeck('John Dee', '90 cartes', Icons.auto_fix_high_rounded),
      const _FeaturedDeck('Dante', '100 cartes', Icons.local_fire_department),
      const _FeaturedDeck('Shakespeare', '90 cartes', Icons.theater_comedy),
      const _FeaturedDeck('DJ WHO', '60 cartes', Icons.graphic_eq_rounded),
      const _FeaturedDeck('Edinburgh', '70 cartes', Icons.castle_rounded),
    ];

    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final deck = featured[index];
          return SizedBox(
            width: 140,
            child: _GoldPanel(
              padding: const EdgeInsets.all(10),
              onTap: index == 0
                  ? () => context.go('/decks/$chansonARepondreUnoDeckId')
                  : () => context.go('/decks'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(deck.icon, color: HomeScreen._gold, size: 44),
                  const SizedBox(height: 10),
                  Text(
                    deck.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: HomeScreen._cream,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(deck.count, style: const TextStyle(color: HomeScreen._cream)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentCards extends StatelessWidget {
  const _RecentCards({required this.cards});

  final List<CardItem> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final card = cards[index];
          return GestureDetector(
            onTap: () => context.go('/cards/${card.id}'),
            child: SizedBox(
              width: 116,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: HomeScreen._gold),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _CardImage(card: card),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xF20F0D0B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HomeScreen._gold),
          ),
          child: SizedBox(
            height: 86,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BottomButton('ACCUEIL', Icons.home_rounded, () => context.go('/')),
                _BottomButton('DECKS', Icons.style_rounded, () => context.go('/decks')),
                _PlayButton(() => context.go('/play')),
                _BottomButton(
                  'JOURNAL',
                  Icons.menu_book_rounded,
                  () => context.go('/journal'),
                ),
                _BottomButton('PLUS', Icons.more_horiz_rounded, () => context.go('/dj-who-videos')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton(this.label, this.icon, this.onTap);

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: HomeScreen._gold),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton(this.onTap);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1C170B),
          border: Border.all(color: HomeScreen._gold, width: 2),
          boxShadow: const [
            BoxShadow(color: HomeScreen._gold, blurRadius: 18),
          ],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: HomeScreen._gold,
          size: 42,
        ),
      ),
    );
  }
}

class _GoldPanel extends StatelessWidget {
  const _GoldPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: HomeScreen._panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomeScreen._gold),
      ),
      child: child,
    );
    if (onTap == null) return panel;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: panel);
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xE60E0C09),
            border: Border.all(color: HomeScreen._gold, width: 1.5),
          ),
          child: Icon(icon, color: HomeScreen._gold, size: 32),
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.card});

  final CardItem card;

  @override
  Widget build(BuildContext context) {
    if (card.source == CardSource.bundled) {
      return Image.asset(card.image, fit: BoxFit.cover);
    }
    return Container(
      color: const Color(0xFF21180F),
      alignment: Alignment.center,
      child: const Icon(Icons.image_rounded, color: HomeScreen._gold),
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.accent,
    required this.semanticsLabel,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color accent;
  final String semanticsLabel;
}

class _FeaturedDeck {
  const _FeaturedDeck(this.title, this.count, this.icon);

  final String title;
  final String count;
  final IconData icon;
}
