import 'package:flutter/material.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';

/// A small product image that animates from [start] to [end] and fades out.
/// Custom AnimatedWidget replacing Framer Motion's flying-product effect.
class FlyingProduct extends StatefulWidget {
  final Product product;
  final ImatDataHandler iMat;
  final Offset start;
  final Offset end;
  final VoidCallback onCompleted;

  const FlyingProduct({
    super.key,
    required this.product,
    required this.iMat,
    required this.start,
    required this.end,
    required this.onCompleted,
  });

  @override
  State<FlyingProduct> createState() => _FlyingProductState();
}

class _FlyingProductState extends State<FlyingProduct>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _ctrl.forward();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        Future.delayed(
          const Duration(milliseconds: 200),
          widget.onCompleted,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FlyingProductAnimation(
      controller: _ctrl,
      start: widget.start,
      end: widget.end,
      child: SizedBox(
        width: 80,
        height: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: widget.iMat.getImage(widget.product),
        ),
      ),
    );
  }
}

/// AnimatedWidget that interpolates position, scale, and opacity.
class _FlyingProductAnimation extends AnimatedWidget {
  final Offset start;
  final Offset end;
  final Widget child;

  const _FlyingProductAnimation({
    required AnimationController controller,
    required this.start,
    required this.end,
    required this.child,
  }) : super(listenable: controller);

  Animation<double> get _t => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeInOut.transform(_t.value);
    final pos = Offset.lerp(start, end, t)!;
    final scale = 0.5 + (0.2 - 0.5) * t; // 0.5 -> 0.2
    final opacity = 1.0 - t;
    return Positioned(
      left: pos.dx - 40,
      top: pos.dy - 40,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(scale: scale, child: child),
        ),
      ),
    );
  }
}
