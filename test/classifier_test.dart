import 'package:fasa/src/classifier.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultFasaClassifier', () {
    late DefaultFasaClassifier classifier;

    setUp(() {
      classifier = DefaultFasaClassifier();
    });

    test('classifies groceries description', () {
      expect(classifier.classify('bought milk and bread'), 'groceries');
    });

    test('classifies utilities description', () {
      expect(classifier.classify('paid electricity bill'), 'utilities');
      expect(classifier.classify('20k madzi'), 'utilities');
      expect(classifier.classify('20k electricity'), 'utilities');
      expect(classifier.classify('20k escom'), 'utilities');
    });

    test('classifies transport description', () {
      expect(classifier.classify('fuel for car'), 'transport');
    });

    test('classifies income description', () {
      expect(classifier.classify('salary from job'), 'income');
    });

    test('classifies transfers_and_fees description', () {
      expect(classifier.classify('sent money via mpamba'), 'transfers_and_fees');
    });

    test('empty description returns unknown', () {
      expect(classifier.classify(''), 'unknown');
    });
  });
}
