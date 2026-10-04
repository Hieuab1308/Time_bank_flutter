import 'package:flutter/material.dart';

Route<T> slideFromBottomRoute<T>(Widget page, {Duration duration = const Duration(milliseconds: 300)}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 0.2), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
      final fade = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation.drive(fade), child: child),
      );
    },
  );
}

Route<T> fadeRoute<T>(Widget page, {Duration duration = const Duration(milliseconds: 250)}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
