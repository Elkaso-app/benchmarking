import 'package:flutter/material.dart';

class FontSizeProvider extends ChangeNotifier {
  double _fontScale = 1.0;

  double get fontScale => _fontScale;

  // Preset sizes
  static const double small = 0.85;
  static const double medium = 1.0;
  static const double large = 1.15;
  static const double extraLarge = 1.3;

  String get currentSizeLabel {
    if (_fontScale <= small) return 'Small';
    if (_fontScale <= medium) return 'Medium';
    if (_fontScale <= large) return 'Large';
    return 'Extra Large';
  }

  void setFontScale(double scale) {
    _fontScale = scale.clamp(0.7, 1.5);
    notifyListeners();
  }

  void increase() {
    if (_fontScale < small) {
      _fontScale = small;
    } else if (_fontScale < medium) {
      _fontScale = medium;
    } else if (_fontScale < large) {
      _fontScale = large;
    } else if (_fontScale < extraLarge) {
      _fontScale = extraLarge;
    }
    notifyListeners();
  }

  void decrease() {
    if (_fontScale > extraLarge) {
      _fontScale = extraLarge;
    } else if (_fontScale > large) {
      _fontScale = large;
    } else if (_fontScale > medium) {
      _fontScale = medium;
    } else if (_fontScale > small) {
      _fontScale = small;
    }
    notifyListeners();
  }

  void reset() {
    _fontScale = medium;
    notifyListeners();
  }
}
