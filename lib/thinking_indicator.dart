// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutterflip/styling.dart';

/// This is a self-animated progress spinner, only instead of spinning it
/// moves five little circles in a horizontal arrangement.
class ThinkingIndicator extends ImplicitlyAnimatedWidget {
  final Color color;
  final double height;
  final bool visible;

  const ThinkingIndicator({
    this.color = const Color(0xffffffff),
    this.height = 10.0,
    this.visible = true,
    super.key,
  }) : super(
          duration: Styling.thinkingFadeDuration,
        );

  @override
  ImplicitlyAnimatedWidgetState createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState
    extends AnimatedWidgetBaseState<ThinkingIndicator> {
  Tween<double>? _opacityTween;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: widget.height,
        child: Opacity(
          opacity: _opacityTween!.evaluate(animation),
          child: _opacityTween!.evaluate(animation) != 0
              ? AnimatedCircles(
                  color: widget.color,
                  height: widget.height,
                )
              : null,
        ),
      ),
    );
  }

  @override
  void forEachTween(visitor) {
    _opacityTween = visitor(
      _opacityTween,
      widget.visible ? 1.0 : 0.0,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }
}

class AnimatedCircles extends StatefulWidget {
  final Color color;
  final double height;

  const AnimatedCircles({
    required this.color,
    required this.height,
    super.key,
  });

  @override
  AnimatedCirclesState createState() => AnimatedCirclesState();
}

class AnimatedCirclesState extends State<AnimatedCircles>
    with SingleTickerProviderStateMixin {
  late Animation<double> _thinkingAnimation;
  late AnimationController _thinkingController;

  @override
  void initState() {
    super.initState();
    _thinkingController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addStatusListener((status) {
        // This bit ensures that the animation reverses course rather than
        // stopping.
        if (status == AnimationStatus.completed) _thinkingController.reverse();
        if (status == AnimationStatus.dismissed) _thinkingController.forward();
      });
    _thinkingAnimation = Tween(begin: 0.0, end: widget.height).animate(
        CurvedAnimation(parent: _thinkingController, curve: Curves.easeOut));
    _thinkingController.forward();
  }

  @override
  void dispose() {
    _thinkingController.dispose();
    super.dispose();
  }

  Widget _buildCircle() {
    return Container(
      width: widget.height,
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.color,
          width: 2.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _thinkingAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCircle(),
            SizedBox(width: _thinkingAnimation.value),
            _buildCircle(),
            SizedBox(width: _thinkingAnimation.value),
            _buildCircle(),
            SizedBox(width: _thinkingAnimation.value),
            _buildCircle(),
            SizedBox(width: _thinkingAnimation.value),
            _buildCircle(),
          ],
        );
      },
    );
  }
}
