import 'package:flutter_test/flutter_test.dart';
import 'package:chanson_a_repondre_uno/providers/deck_provider.dart';
import 'package:chanson_a_repondre_uno/providers/card_browser_provider.dart';

void main() {
  test('permanent deck exposes 67 unique cards and shuffle preserves them', () async {
    final deck = DeckProvider.permanentDeck;
    expect(deck.id, chansonARepondreUnoDeckId);
    expect(deck.cards, hasLength(67));
    expect(deck.cards.map((c) => c.id).toSet(), hasLength(67));
    expect(deck.cards.first.id, 'chanson-a-repondre-uno-001');
    expect(deck.cards.last.id, 'chanson-a-repondre-uno-067');

    final browser = CardBrowserProvider();
    browser.initializeForDeck(deck.id, deck.cards);
    await browser.generateRandomHand();
    expect(browser.visibleHand, hasLength(67));
    expect(browser.visibleHand.map((c) => c.id).toSet(), hasLength(67));

    browser.resetToFirstCards();
    expect(
      browser.visibleHand.map((c) => c.id).toList(),
      deck.cards.map((c) => c.id).toList(),
    );
  });
}
