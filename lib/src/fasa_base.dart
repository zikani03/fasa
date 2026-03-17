final lineExprLTR = RegExp(
    r'(<|\+|-|>)?\s?((\d*\.?\d{0,3})(k|K|j|J|l|L|pin|n|N|m|M|mita|grand)?)(\s?\w.*$)',
    multiLine: false,
    caseSensitive: false);


final lineExprRTL = RegExp(
    r'(\s?\w.*)\s+(<|\+|-|>)?((\d*\.?\d{0,3})(k|K|j|J|l|L|pin|m|M|n|N|mita|grand)?)$',
    multiLine: false,
    caseSensitive: false);   

String expandShorthand2(String input) {
  // Define the multipliers
  final Map<String, double> multipliers = {
    'j': 1000, // typo-tolerance for k
    'k': 1000,
    'l': 1000, // typo-tolerance for k
    'pin': 1000,
    'grand': 1000,
    'm': 1000000,
    'n': 1000000, // typo-tolerance for m
    'mita': 1000000,
    'b': 1000000000,
  };

// 1. Join keys: "k|pin|m|mita|b"
  final keys = multipliers.keys.join('|');
  
  // 2. The Regex:
  // ([0-9]+\.?[0-9]*) -> Group 1: The number (integer or decimal)
  // ($keys)           -> Group 2: MUST be one of our shorthand keys
  // \b                -> Word boundary (prevents matching "k" in "keyboard")
  final regExp = RegExp('([0-9]+\\.?[0-9]*)($keys)\\b', caseSensitive: false);

  return input.replaceAllMapped(regExp, (Match match) {
    double num = double.parse(match.group(1)!);
    String suffix = match.group(2)!.toLowerCase();

    double multiplier = multipliers[suffix]!;
    double result = num * multiplier;

    // Format output: remove trailing .0 if it's a whole number
    return result % 1 == 0 ? result.toInt().toString() : result.toString();
  });
}