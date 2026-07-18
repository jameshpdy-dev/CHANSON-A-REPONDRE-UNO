import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chanson_a_repondre_uno/app.dart';
import 'package:chanson_a_repondre_uno/data/chanson_a_repondre_uno_deck.dart';
import 'package:chanson_a_repondre_uno/models/card_item.dart';
import 'package:chanson_a_repondre_uno/repositories/card_repository.dart';

void main() {
  testWidgets('renders accessible poster hotspots', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ChansonARepondreUnoApp());

    expect(find.bySemanticsLabel('Play'), findsOneWidget);
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
  });

  testWidgets(
    'permanent deck is visible from deck, search, and diagnostics flows',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ChansonARepondreUnoApp(cardRepository: _MemoryCardRepository()),
      );
      await _pumpRoute(tester);

      await tester.ensureVisible(find.text('Choose Deck'));
      await tester.tap(find.text('Choose Deck'));
      await _pumpUntilFound(tester, find.text(chansonARepondreUnoDeckName));

      expect(find.text(chansonARepondreUnoDeckName), findsWidgets);
      expect(find.text('67 cards'), findsOneWidget);
      expect(find.text('Permanent deck'), findsOneWidget);

      await tester.tap(find.text(chansonARepondreUnoDeckName).first);
      await _pumpUntilFound(tester, find.text('Card 001'));

      expect(find.text(chansonARepondreUnoDeckName), findsWidgets);
      expect(find.text('Card 001'), findsOneWidget);

      await tester.tap(find.byTooltip('Choose Deck'));
      await _pumpRoute(tester);
      await tester.tap(find.byTooltip('Home'));
      await _pumpRoute(tester);

      await tester.ensureVisible(find.text('Search'));
      await tester.tap(find.text('Search'));
      await _pumpRoute(tester);
      await tester.enterText(find.byType(SearchBar), 'Card 067');
      await _pumpUntilFound(tester, find.text('Card 067'));

      expect(find.text('Card 067'), findsWidgets);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await _pumpRoute(tester);

      await tester.ensureVisible(find.text('Diagnostics'));
      await tester.tap(find.text('Diagnostics'));
      await _pumpUntilFound(tester, find.text('root-100-card-webapp'));

      expect(find.text('App variant'), findsOneWidget);
      expect(find.text('root-100-card-webapp'), findsOneWidget);
      expect(find.text('Bundled cards'), findsOneWidget);
      expect(find.text('67'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('Library status'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Library status'), findsOneWidget);
    },
  );
}

Future<void> _pumpRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
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
