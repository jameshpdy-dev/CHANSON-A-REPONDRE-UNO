import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chanson_2/models/card_image_model.dart';
import 'package:uno_chanson_2/providers/card_browser_provider.dart';

void main() {
  test(
    'selects exactly five unique cards without mutating source order',
    () async {
      final source = List.generate(9, _card);
      final originalIds = source.map((card) => card.id).toList();
      final provider = CardBrowserProvider(random: Random(4));
      provider.initializeForDeck('deck', source);
      await _settle();
      expect(provider.visibleHand, hasLength(5));
      expect(provider.visibleHand.map((card) => card.id).toSet(), hasLength(5));
      expect(source.map((card) => card.id), originalIds);
    },
  );

  test('fewer than five cards are returned without duplicates', () async {
    final provider = CardBrowserProvider(random: Random(2));
    provider.initializeForDeck('deck', List.generate(3, _card));
    await _settle();
    expect(provider.visibleHand, hasLength(3));
    expect(provider.visibleHand.map((card) => card.id).toSet(), hasLength(3));
  });

  test(
    'same deck rebuild preserves hand and explicit shuffle changes it',
    () async {
      final cards = List.generate(10, _card);
      final provider = CardBrowserProvider(random: Random(8));
      provider.initializeForDeck('deck', cards);
      await _settle();
      final first = provider.visibleHand.map((card) => card.id).toList();
      provider.initializeForDeck('deck', cards);
      expect(provider.visibleHand.map((card) => card.id), first);
      await provider.generateRandomHand();
      expect(
        provider.visibleHand.map((card) => card.id).toList(),
        isNot(first),
      );
    },
  );

  test('reset returns first five cards in saved order', () async {
    final cards = List.generate(8, _card);
    final provider = CardBrowserProvider(random: Random(3));
    provider.initializeForDeck('deck', cards);
    await _settle();
    provider.resetToFirstCards();
    expect(
      provider.visibleHand.map((card) => card.id),
      cards.take(5).map((card) => card.id),
    );
  });

  test('filtered shuffle uses only matching cards', () async {
    final cards = List.generate(
      8,
      (index) => _card(index, category: index.isEven ? 'Parole' : 'Mémoire'),
    );
    final provider = CardBrowserProvider(random: Random(5));
    provider.initializeForDeck('deck', cards);
    await _settle();
    provider.applyFilters(category: 'Mémoire');
    await _settle();
    expect(provider.visibleHand, isNotEmpty);
    expect(
      provider.visibleHand.every((card) => card.category == 'Mémoire'),
      isTrue,
    );
  });

  test('active deck change creates a new hand', () async {
    final provider = CardBrowserProvider(random: Random(6));
    provider.initializeForDeck('first', List.generate(6, _card));
    await _settle();
    provider.initializeForDeck(
      'second',
      List.generate(6, (index) => _card(index + 20)),
    );
    await _settle();
    expect(provider.deckId, 'second');
    expect(
      provider.visibleHand.every((card) => card.id.startsWith('card-2')),
      isTrue,
    );
  });
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 230));

CardImageModel _card(int index, {String category = 'Parole'}) => CardImageModel(
  id: 'card-$index',
  deckId: 'deck',
  title: 'Card $index',
  path: 'assets/images/card_back.png',
  category: category,
  colour: 'red',
  importedAt: DateTime(2026),
  imageWidth: 800,
  imageHeight: 1200,
);
