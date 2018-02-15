// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

class ThinkingIndicator extends AnimatedWidget {
  ThinkingIndicator(
      {Key key, Animation<double> animation, this.color, this.size})
      : super(key: key, listenable: animation);

  final Color color;
  final double size;

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return new Center(
      child: new SizedBox(
        child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: new List<Widget>.generate(
                5,
                    (_) => new Padding(
                    padding:
                    new EdgeInsets.symmetric(horizontal: animation.value),
                    child: new Container(
                        width: this.size,
                        height: this.size,
                        decoration: new BoxDecoration(
                          border: new Border.all(color: this.color, width: 2.0),
                          borderRadius:
                          new BorderRadius.all(const Radius.circular(5.0)),
                        )))).toList()),
      ),
    );
  }
}