import 'package:flutter/material.dart';

class AppBorderRadius {
  AppBorderRadius._();

  static const double s = 4.0;
  static const double m = 8.0;
  static const double l = 12.0;
  static const double xl = 16.0;
  static const double circular = 9999.0;

  // BorderRadius objects
  static const BorderRadius allS = BorderRadius.all(Radius.circular(s));
  static const BorderRadius allM = BorderRadius.all(Radius.circular(m));
  static const BorderRadius allL = BorderRadius.all(Radius.circular(l));
  static const BorderRadius allXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius allCircular = BorderRadius.all(Radius.circular(circular));
}
