import 'package:flutter/material.dart';
import 'animation_constants.dart';

class PageTransitions {
  // Slide transition from right
  static Route<T> slideFromRight<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AnimationConstants.normalDuration,
      reverseTransitionDuration: AnimationConstants.fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = AnimationConstants.slideFromRight;
        const end = AnimationConstants.slideCenter;
        
        final slideTween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimationConstants.slideCurve,
        );
        
        return SlideTransition(
          position: slideTween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
  
  // Slide transition from bottom
  static Route<T> slideFromBottom<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AnimationConstants.normalDuration,
      reverseTransitionDuration: AnimationConstants.fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = AnimationConstants.slideFromBottom;
        const end = AnimationConstants.slideCenter;
        
        final slideTween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimationConstants.bounceCurve,
        );
        
        return SlideTransition(
          position: slideTween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
  
  // Fade transition
  static Route<T> fadeTransition<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AnimationConstants.normalDuration,
      reverseTransitionDuration: AnimationConstants.fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimationConstants.fadeCurve,
        );
        
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      },
    );
  }
  
  // Scale transition with fade
  static Route<T> scaleTransition<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AnimationConstants.normalDuration,
      reverseTransitionDuration: AnimationConstants.fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = AnimationConstants.scaleFrom;
        const end = AnimationConstants.scaleTo;
        
        final scaleTween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimationConstants.bounceCurve,
        );
        
        return ScaleTransition(
          scale: scaleTween.animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
  
  // Custom combined transition
  static Route<T> slideAndFadeTransition<T extends Object?>(
    Widget page, {
    Offset slideBegin = AnimationConstants.slideFromRight,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AnimationConstants.normalDuration,
      reverseTransitionDuration: AnimationConstants.fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const slideEnd = AnimationConstants.slideCenter;
        
        final slideTween = Tween(begin: slideBegin, end: slideEnd);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimationConstants.defaultCurve,
        );
        
        return SlideTransition(
          position: slideTween.animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}

// Extension for easy navigation with animations
extension AnimatedNavigation on NavigatorState {
  Future<T?> pushWithSlideFromRight<T extends Object?>(Widget page) {
    return push(PageTransitions.slideFromRight<T>(page));
  }
  
  Future<T?> pushWithSlideFromBottom<T extends Object?>(Widget page) {
    return push(PageTransitions.slideFromBottom<T>(page));
  }
  
  Future<T?> pushWithFade<T extends Object?>(Widget page) {
    return push(PageTransitions.fadeTransition<T>(page));
  }
  
  Future<T?> pushWithScale<T extends Object?>(Widget page) {
    return push(PageTransitions.scaleTransition<T>(page));
  }
  
  Future<T?> pushWithSlideAndFade<T extends Object?>(
    Widget page, {
    Offset slideBegin = AnimationConstants.slideFromRight,
  }) {
    return push(PageTransitions.slideAndFadeTransition<T>(page, slideBegin: slideBegin));
  }
}
