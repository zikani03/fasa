// const EntryType = "CREDIT"|"DEBIT"|"INCOMING"|"OUTGOING";


import 'package:fasa/fasa.dart';
import 'package:formula_parser/formula_parser.dart';

class Entry {
  final String id;
  final String description;
  final double amount;
  final String opType;


  Entry(
    this.id,
    this.opType,
    this.amount,
    this.description,
  );

  static double amountFromDenomination(double v, String denomination) {
    var amount = v;
    if (denomination == 'k' ||
        denomination == 'pin' ||
        denomination == 'grand') {
      amount = amount * 1000.00;
    } else if (denomination == 'mita' ||
        denomination == 'm' ||
        denomination == 'million') {
      amount = amount * 1000000.00;
    }
    return amount;
  }

  static Entry tryParse(String v) {
    try {
      return parseLine(v);
    } catch(e) {
      try {
        return parseLineRTL(v);
      } catch(e) {
        throw Exception("failed to parse expression into Entry got ${e.toString()}");
      }
    }
  }

  static Entry parseLine(String v) {
    var res = lineExprLTR.firstMatch(v);
    if (res == null) {
      throw Exception("could not parse string");
    }

    var amount = double.parse('${res.group(3)}');
    var denomination = '${res.group(4)}'.trim().toLowerCase();
    amount = amountFromDenomination(amount, denomination);

    var entry = Entry(
      'txn-${DateTime.now().millisecond}',
      res.group(1) == ">" || res.group(1) == "+" ? "CREDIT" : "DEBIT",
      amount,
      '${res.group(5)}'.trim(),
    );
    return entry;
  }

  static Entry parseLineRTL(String v) {
    var res = lineExprRTL.firstMatch(v.trim());
    if (res == null) {
      throw Exception("could not parse string");
    }
    var amount = double.parse('${res.group(4)}');
    var denomination = '${res.group(5)}'.trim().toLowerCase();
    amount = amountFromDenomination(amount, denomination);

    var entry = Entry(
      'txn-${DateTime.now().millisecond}',
      res.group(2) == ">" || res.group(2) == "+" ? "CREDIT" : "DEBIT",
      amount,
      '${res.group(1)}'.trim(),
    );
    return entry;
  }

  static Entry parseExpressionAsTransaction(String userInput) {
    var parts = userInput.split(' ');
    try {
      var exp = FormulaParser(parts[0]);
      if (!exp.error) {
        var result = exp.parse;
        if (result['isSuccess']) {
          var amount = result['value'];
          return Entry.parseLine('$amount ${parts.sublist(1).join(' ')}');
        } else {
          throw Exception('failed to parse expression');
        }
      } else {
        throw Exception('failed to parse expression got ${exp.errorMessage}');
      }
    } catch (e) {
      // Default to parsing the line without expressions
      return Entry.parseLine(userInput);
    }
  }
}
