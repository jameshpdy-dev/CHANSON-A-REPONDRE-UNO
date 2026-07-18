import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:chanson_a_repondre_uno/app.dart';
import 'package:chanson_a_repondre_uno/data/chanson_a_repondre_uno_deck.dart';
import 'package:chanson_a_repondre_uno/models/card_item.dart';
import 'package:chanson_a_repondre_uno/repositories/card_repository.dart';

void main() {
  testWidgets('renders accessible poster hotspots', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChansonARepondreUnoApp(cardRepository: _MemoryCardRepository()),
    );
    await _pumpRoute(tester);

    expect(find.text('UNO!'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('CHOISIR UN DECK'), findsOneWidget);
    expect(find.text('PARCOURIR LES CARTES'), findsOneWidget);
    expect(find.text('RECHERCHER'), findsOneWidget);
    expect(find.text('DECKS EN VEDETTE'), findsOneWidget);
    expect(find.text('CARTES RÉCENTES'), findsOneWidget);
    expect(find.text('Diagnostics'), findsNothing);
  });

  testWidgets(
    'permanent deck is visible from restored deck, browse, search, and viewer flows',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ChansonARepondreUnoApp(cardRepository: _MemoryCardRepository()),
      );
      await _pumpRoute(tester);

      _goTo(tester, '/decks');
      await _pumpUntilFound(tester, find.text(chansonARepondreUnoDeckName));

      expect(find.text('Deck Selection'), findsOneWidget);
      expect(find.text(chansonARepondreUnoDeckName), findsWidgets);
      expect(find.text('67 cards'), findsOneWidget);
      expect(find.text('Permanent deck'), findsOneWidget);

      _goTo(tester, '/decks/$chansonARepondreUnoDeckId');
      await _pumpUntilFound(tester, find.text('Card 001'));

      expect(find.text(chansonARepondreUnoDeckName), findsWidgets);
      expect(find.text('Card 001'), findsOneWidget);

      _goTo(tester, '/cards');
      await _pumpUntilFound(tester, find.text('Browse Cards'));
      expect(find.text('0 / 100 cards stored'), findsOneWidget);
      expect(find.text('Card 001'), findsWidgets);
      expect(find.textContaining('.png'), findsNothing);

      _goTo(tester, '/cards/chanson-a-repondre-uno-001');
      await _pumpUntilFound(tester, find.text('Card Viewer'));
      expect(find.byType(Image), findsWidgets);
      expect(find.text(chansonARepondreUnoDeckName.toUpperCase()), findsWidgets);

      _goTo(tester, '/search');
      await _pumpRoute(tester);
      await tester.enterText(find.byType(SearchBar), 'Card 001');
      await _pumpUntilFound(tester, find.text('Card 001'));

      expect(find.text('Card 001'), findsWidgets);
      expect(find.textContaining('.png'), findsNothing);
    },
  );

  testWidgets('diagnostics route reports the permanent runtime count', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChansonARepondreUnoApp(cardRepository: _MemoryCardRepository()),
    );
    await _pumpRoute(tester);

    _goTo(tester, '/diagnostics');
    await _pumpUntilFound(tester, find.text('root-100-card-webapp'));

    expect(find.text('App variant'), findsOneWidget);
    expect(find.text('Bundled cards'), findsOneWidget);
    expect(find.text('67'), findsWidgets);
  });

  testWidgets('restored profile and DJ WHO routes remain reachable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ChansonARepondreUnoApp());
    await _pumpRoute(tester);

    _goTo(tester, '/profile');
    await _pumpUntilFound(tester, find.text('Profile'));
    expect(find.text('Profile'), findsOneWidget);

    _goTo(tester, '/dj-who-videos');
    await _pumpUntilFound(tester, find.text('DJ WHO Videos'));
    expect(find.text('DJ WHO Videos'), findsOneWidget);
  });
}

Future<void> _pumpRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void _goTo(WidgetTester tester, String location) {
  GoRouter.of(tester.element(find.byType(Navigator).first)).go(location);
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int attempts = 20,
}) async {
  for (var i = 0; i < attempts; i++) {
    await _pumpRoute(tester);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
}

class _MemoryCardRepository implements CardRepository {
  final List<CardItem> _cards = List.generate(chansonARepondreUnoCardCount, (
    index,
  ) {
    final sequence = index + 1;
    final padded = sequence.toString().padLeft(3, '0');
    return CardItem(
      id: 'chanson-a-repondre-uno-$padded',
      deckId: chansonARepondreUnoDeckId,
      title: 'Card $padded',
      question: '$chansonARepondreUnoDeckName permanent card $sequence',
      answer: '',
      image: 'assets/cards/chanson_a_repondre_uno/card_$padded.png',
      audio: '',
      video: '',
      category: chansonARepondreUnoDeckName,
      colour: 'black',
      quote: '',
      author: '',
      year: 2026,
      tags: const ['permanent deck', 'bundled'],
      favorite: false,
      source: CardSource.bundled,
    );
  });

  @override
  Future<List<CardItem>> loadCards() async => List.of(_cards);

  @override
  Future<ImportBatchResult> importCards(
    List<CardImportCandidate> candidates, {
    void Function(int completed, int total)? onProgress,
  }) async => const ImportBatchResult(
    imported: 0,
    duplicates: 0,
    invalid: 0,
    tooLarge: 0,
    unsupported: 0,
    capacitySkipped: 0,
    errors: 0,
  );

  @override
  Future<void> deleteImportedCard(String id) async {}

  @override
  Future<void> clearImportedCards() async {}

  @override
  Future<Uint8List?> readStoredImage(String reference) async => null;
}
