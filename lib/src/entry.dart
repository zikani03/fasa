import 'package:fasa/fasa.dart';
import 'package:fasa/src/classifier.dart';
import 'package:formula_parser/formula_parser.dart';

class Entry {
  final String id;
  final String description;
  final double amount;
  final String opType;
  final String category;


  Entry(
    this.id,
    this.opType,
    this.amount,
    this.description,
    { this.category = 'misc'}
  );

  @override
  String toString() {
    return 'id: ${this.id}, description: ${this.description}, amount: ${this.amount}, opType: ${this.opType}, category: ${this.category}';
  }

  static double amountFromDenomination(double v, String denomination) {
    var amount = v;
    if (denomination == 'k' || (denomination == "j" || denomination == "l") || // j and l are typo-tolerant for k
        denomination == 'pin' ||
        denomination == 'grand') {
      amount = amount * 1000.00;
    } else if (denomination == 'mita' ||
        denomination == 'm' || (denomination == "n") || // n is typo-tolerant for m
        denomination == 'million') {
      amount = amount * 1000000.00;
    }
    return amount;
  }

  static Entry tryParse(String v, {FasaClassifier? classifier}) {
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

  static Entry parseLine(String v, {bool withFormula = true}) {
    v = expandShorthand2(v);
    
    if (withFormula) {
      var expanded = tryEvaluateFormula(v, false);
      return expanded;
    }
    var res = lineExprLTR.firstMatch(v);
    if (res == null) {
      throw Exception("could not parse string");
    }

    var amount = double.parse('${res.group(3)}');
    var denomination = '${res.group(4)}'.trim().toLowerCase();
    amount = amountFromDenomination(amount, denomination);

    var entry = Entry(
      'txn-${DateTime.now().millisecond}',
      "UNKNOWN", //res.group(1) == ">" || res.group(1) == "+" ? "CREDIT" : "DEBIT",
      amount,
      'kaya', //'${res.group(5)}'.trim(),
    );
    return entry;
  }

  static Entry parseLineRTL(String v, { bool withFormula = true }) {
    v = expandShorthand2(v.trim());
    if (withFormula) {
      var expanded = tryEvaluateFormula(v, true);
      return expanded;
    }

    var res = lineExprRTL.firstMatch(v);
    if (res == null) {
      throw Exception("could not parse string");
    }
    var amount = double.parse('${res.group(4)}');
    var denomination = '${res.group(5)}'.trim().toLowerCase();
    amount = amountFromDenomination(amount, denomination);

    var entry = Entry(
      'txn-${DateTime.now().millisecond}',
      "UNKNOWN", //res.group(2) == ">" || res.group(2) == "+" ? "CREDIT" : "DEBIT",
      amount,
      '${res.group(1)}'.trim(),
    );
    return entry;
  }

  static Entry tryEvaluateFormula(String userInput, bool isRTL) {
    var parts = userInput.split(' ');
    try {
      if (parts.isEmpty) {
        throw Exception('invalid expression: $userInput');
      }
      var expr = parts[0];
      if (parts.length >= 2 && isRTL) {
        expr = parts[1];
      }
      
      var exp = FormulaParser(expr);
      if (!exp.error) {
        var result = exp.parse;
        if (result['isSuccess']) {
          var amount = result['value'];

          if (isRTL) {
            return Entry(
              'id',
              'UNKNOWN',
              amount,
              parts[0],
            );
          }
          return Entry(
            'id',
            'UNKNOWN',
            amount,
            parts.sublist(1).join(' '),
          );
        } else {
          throw Exception('failed to parse expression');
        }
      } else {
        throw Exception('failed to parse expression got ${exp.errorMessage}');
      }
    } catch (e) {
      print('defaulting to parsing without formula for $userInput got $e');
      if (isRTL) {
        return Entry.parseLineRTL(userInput, withFormula: false);
      }
      return Entry.parseLine(userInput, withFormula: false);
    }
  }
}
