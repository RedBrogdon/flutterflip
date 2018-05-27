// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// This is a self-animated progress spinner, only instead of spinning it
/// moves five little circles in a horizontal arrangement.
class ThinkingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  ThinkingIndicator(
      {this.color: const Color(0xffffffff), this.size: 10.0, Key key})
      : super(key: key);

  @override
  State createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  Animation<double> _thinkingAnimation;
  AnimationController _thinkingController;

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
    _thinkingAnimation = Tween(begin: 0.0, end: widget.size).animate(
        CurvedAnimation(parent: _thinkingController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });
    _thinkingController.forward();
  }

  @override
  void dispose() {
    _thinkingController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(
            5,
            (_) => Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: _thinkingAnimation.value),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      border: Border.all(color: widget.color, width: 2.0),
                      borderRadius:
                          BorderRadius.all(const Radius.circular(5.0)),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
