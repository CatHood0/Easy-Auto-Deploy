import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DefaultShimmerTile extends StatelessWidget {
  final Widget child;
  const DefaultShimmerTile({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.white,
      loop: 9999999,
      direction: ShimmerDirection.ltr,
      enabled: true,
      period: Duration(milliseconds: 500),
      child: child,
    );
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height = 12.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.white.withAlpha(30),
      child: child,
    );
  }
}
