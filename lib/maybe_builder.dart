// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// This class probably isn't necessary, but it makes the [Widget]-building code
/// in main.dart cleaner in one place. There's a spot where a [Widget] may or
/// may not be included at the end of a list of children. Having the
/// [MaybeBuilder] handle this avoids an ugly ternary expression, and abstracts
/// away what [Widget] gets used as the "I don't want to have anything here"
/// placeholder (currently a 0x0 [Container]).
class MaybeBuilder extends StatelessWidget {
  final bool condition;
  final WidgetBuilder builder;

  MaybeBuilder({this.condition, this.builder}) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return builder(context);
    } else {
      return Container(height: 0.0, width: 0.0);
    }
  }
}
