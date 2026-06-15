import 'dart:math' as math;

import 'package:fasa/src/_classifier_data.dart';

mixin FasaClassifier {
  String classify(String description);
}

class DefaultFasaClassifier implements FasaClassifier {
  final Map<String, Map<String, int>> _dataset;
  final Map<String, int> _categoryWordCounts = {};
  final Set<String> _vocabulary = {};
  late final double _priorProbability;

  DefaultFasaClassifier({Map<String, Map<String, int>>? dataset}) 
      : _dataset = dataset ?? malawianFinancialDataset {
    _initializeModel();
  }

  void _initializeModel() {
    for (var entry in _dataset.entries) {
      final category = entry.key;
      final words = entry.value;
      
      int totalWords = 0;
      for (var wordEntry in words.entries) {
        totalWords += wordEntry.value;
        _vocabulary.add(wordEntry.key);
      }
      _categoryWordCounts[category] = totalWords;
    }
    // Prior probability assumes uniform distribution across categories for short strings
    _priorProbability = 1.0 / _dataset.length;
  }

  /// Cleans and extracts relevant text tokens
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'\d+k?\b|\b\d+k?'), '') // Clean isolated numbers/shorthands like 30k or 1500
        .replaceAll(RegExp(r'[^\w\s]'), ' ')         // Replace punctuation with spaces to separate stuck tokens
        .split(RegExp(r'\s+'))                       // Split on any whitespace
        .where((token) => token.length > 1)          // Filter out single character noise
        .toList();
  }

  /// Classifies the input text string into a financial category
  @override
  String classify(String description) {
    final tokens = _tokenize(description);
    if (tokens.isEmpty) return 'unknown';

    String bestCategory = 'unknown';
    double highestLogProb = -double.infinity;

    final vocabSize = _vocabulary.length;

    for (var category in _dataset.keys) {
      // Start with log of the prior probability to prevent underflow
      double logProb = math.log(_priorProbability);
      final totalCategoryWords = _categoryWordCounts[category] ?? 0;
      final wordFrequencies = _dataset[category] ?? {};

      for (var token in tokens) {
        final count = wordFrequencies[token] ?? 0;
        
        // Multinomial Naive Bayes with Laplace Smoothing: (count + 1) / (total + vocabSize)
        final wordProb = (count + 1.0) / (totalCategoryWords + vocabSize);
        logProb += math.log(wordProb);
      }

      if (logProb > highestLogProb) {
        highestLogProb = logProb;
        bestCategory = category;
      }
    }

    return bestCategory;
  }
}