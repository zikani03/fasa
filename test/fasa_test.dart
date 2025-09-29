import 'package:fasa/fasa.dart';
import 'package:test/test.dart';

void main() {
  group('Test parsing LTR expressions', () {
    setUp(() {
      // Additional setup goes here.
    });

  test('Entry should be parsed from regular text', () {
    var expressions = [
      '3k potatoes',
      '3000 potatoes',
      '3.0k potatoes',
      '3000.00 potatoes',
      '>3k potatoes',
      '+3k potatoes',
    ];
    for (var expr in expressions) {
      var entry = Entry.parseLine(expr);
      expect(entry.amount, 3000.00, reason: "failed with expression $expr");
      expect(entry.description, 'potatoes', reason: "failed with expression $expr");
    }
  });
  });

  group('Test parsing RTL expressions', () {
    setUp(() {
      // Additional setup goes here.
    });

  test('Entry should be parsed from regular text', () {
    var expressions = [
      'potatoes 3k',
      'potatoes 3000',
      'potatoes 3.0k',
      'potatoes 3000.00',
      'potatoes >3k',
      'potatoes +3k',
      'potatoes +3j',
      'potatoes +3l',
    ];
    for (var expr in expressions) {
      var entry = Entry.parseLineRTL(expr);
      expect(entry.amount, 3000.00, reason: "failed with expression $expr");
      expect(entry.description, 'potatoes', reason: "failed with expression $expr");
    }
  });
  });

  group('Test tag parsing logic', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Empty tags when text is empty', () {
      expect([], parseTags(""));
    });
    test('Tags can be parsed from text', () {
      expect(['food', 'groceries', 'stuff'], parseTags("[food,groceries,stuff]"));
    });
    test('Weird tags', () {
      expect(['food', 'groceries', 'stuff'], parseTags("[[food],[groceries],[stuff]]"));
    });
    test('Weird tags with empty tags', () {
      expect(['food', 'groceries', 'stuff'], parseTags("[[food],,,,,,[groceries],[stuff]]"));
    });

    test('Tags are trimmed can be parsed from text', () {
      expect(['food', 'groceries', 'stuff'], parseTags("[food    ,   groceries,   stuff  ]"));
    });
  });

  
}
