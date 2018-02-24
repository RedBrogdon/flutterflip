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
  State createState() => new _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  Animation<double> _thinkingAnimation;
  AnimationController _thinkingController;

  @override
  void initState() {
    super.initState();
    _thinkingController = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addStatusListener((status) {
        // This bit ensures that the animation reverses course rather than
        // stopping.
        if (status == AnimationStatus.completed) _thinkingController.reverse();
        if (status == AnimationStatus.dismissed) _thinkingController.forward();
      });
    _thinkingAnimation = new Tween(begin: 0.0, end: widget.size).animate(
        new CurvedAnimation(parent: _thinkingController, curve: Curves.easeOut))
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
    return new Center(
      child: new SizedBox(
        child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: new List<Widget>.generate(
                5,
                (_) => new Padding(
                    padding: new EdgeInsets.symmetric(
                        horizontal: _thinkingAnimation.value),
                    child: new Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: new BoxDecoration(
                          border:
                              new Border.all(color: widget.color, width: 2.0),
                          borderRadius:
                              new BorderRadius.all(const Radius.circular(5.0)),
                        )))).toList()),
      ),
    );
  }
}
