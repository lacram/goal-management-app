import 'package:flutter/material.dart';

class AnimationConstants {
  // Duration Constants
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration extraSlowDuration = Duration(milliseconds: 800);
  
  // Curve Constants
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutCubic;
  static const Curve fadeCurve = Curves.easeInOut;
  
  // Scale Constants
  static const double scaleFrom = 0.8;
  static const double scaleTo = 1.0;
  
  // Slide Constants
  static const Offset slideFromBottom = Offset(0.0, 1.0);
  static const Offset slideFromRight = Offset(1.0, 0.0);
  static const Offset slideFromLeft = Offset(-1.0, 0.0);
  static const Offset slideFromTop = Offset(0.0, -1.0);
  static const Offset slideCenter = Offset(0.0, 0.0);
  
  // Rotation Constants
  static const double rotationAngle = 0.1;
  
  // Stagger Constants
  static const double staggerDelay = 0.1;
  static const int maxStaggerItems = 10;
}

class AnimationTimings {
  static Duration getStaggeredDelay(int index) {
    return Duration(
      milliseconds: (index * AnimationConstants.staggerDelay * 1000).round(),
    );
  }
  
  static Duration getScaledDuration(Duration baseDuration, double factor) {
    return Duration(
      milliseconds: (baseDuration.inMilliseconds * factor).round(),
    );
  }
}
