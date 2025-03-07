import 'package:fasa/fasa.dart';

void main() {
  print(Entry.parseLine("30k Sugar").amount);
  print(Entry.parseLineRTL("Sugar 30k").amount);
}
