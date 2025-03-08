# fasa

Support for parsing a somewhat natural language expression into objects for use in Finance applications. 

## Features

- Parse expressions with full numbers `12500 Milk and eggs`
- Parse expressions with shorthand `12.5k Milk and eggs`
- Supports expressions written with amount first (LTR)  e.g. `1.5k Milk and eggs`
- Supports expressions written with description first (RTL) e.g. `Milk and eggs 1.5k`
- Supports formulas via formula parser for LTR expressions e.g. `300*5 Milk and eggs`

## Getting started

Add to your `pubspec.yaml`

## Usage

See examples in `/example` folder. 

```dart
void main() {
  print(Entry.parseLine("30k Sugar").amount);
  print(Entry.parseLineRTL("Sugar 30k").amount);
}
```

The expression is parsed to an instance of the following class

```dart
class Entry {
  final String id;
  final String description;
  final double amount;
  final String opType;
}
```

