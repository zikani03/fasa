
/*
  * Matches
  * 
  * > 30k something
  * < 30k another thing
  * +50k something very random
  * -50000 another thing
  * > 20 mita on something
  * <1 mita something else
  */
final lineExprLTR = RegExp(
    r'(<|\+|-|>)?\s?((\d*\.?\d{0,3})(k|K|j|J|l|L|pin|n|N|m|M|mita|grand)?)(\s?\w.*$)',
    multiLine: false,
    caseSensitive: false);

/*
  * Matches Right to Left variants
  * 
  * something 30k 
  * another thing < 30k 
  * something very random +50k 
  * another thing -50000 
  * on something > 20 mita
  * something else <1 mita 
  */
final lineExprRTL = RegExp(
    r'(\s?\w.*)\s+(<|\+|-|>)?((\d*\.?\d{0,3})(k|K|j|J|l|L|pin|m|M|n|N|mita|grand)?)$',
    multiLine: false,
    caseSensitive: false);
