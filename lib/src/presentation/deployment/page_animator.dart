import 'package:flutter/material.dart';
import 'drawer/menu_drawer.dart';

enum PageAnimationType {
  fade,
  slideHorizontal,
  slideVertical,
  scale,
  fadeScale,
}

class PageAnimator extends StatelessWidget {
  const PageAnimator({
    super.key,
    required this.currentPage,
    required this.animationType,
    required this.child,
  });

  final DrawerPage currentPage;
  final Widget? child;
  final PageAnimationType animationType;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return _buildTransition(child, animation);
      },
      child: child,
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    switch (animationType) {
      case PageAnimationType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case PageAnimationType.slideHorizontal:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case PageAnimationType.slideVertical:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case PageAnimationType.scale:
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      case PageAnimationType.fadeScale:
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.9,
              end: 1.0,
            ).animate(animation),
            child: child,
          ),
        );
    }
  }
}
