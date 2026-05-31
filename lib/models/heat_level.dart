import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Heat classification derived from the current temperature.
enum HeatLevel {
  comfortable(label: 'Comfortable', color: Colors.green),
  warm(label: 'Warm', color: Colors.orange),
  hot(label: 'Hot', color: Colors.deepOrange),
  extreme(label: 'Extreme', color: Colors.red);

  const HeatLevel({required this.label, required this.color});

  final String label;
  final Color color;

  /// Returns the heat level for a given temperature in °C.
  static HeatLevel fromTemperature(double t) {
    if (t >= TemperatureThreshold.extremeThreshold) return HeatLevel.extreme;
    if (t >= TemperatureThreshold.hotThreshold) return HeatLevel.hot;
    if (t >= TemperatureThreshold.warmThreshold) return HeatLevel.warm;
    return HeatLevel.comfortable;
  }
}
