// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'game_board.dart';

/// The Theme class is part of Flutter's Material Design package, which this
/// game doesn't use. Instead, this static class is used as a convenient spot to
/// hold constants for colors, text styles, and so on.
///
/// While a larger app would need something more sophisticated, for a simple,
/// one-screen game, this gets the job done just fine.
abstract class Styling {
  // **** GRADIENTS AND COLORS ****

  static final Map<PieceType, LinearGradient> pieceGradients = {
    PieceType.black: new LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        new Color(0xff101010),
        new Color(0xff303030),
      ],
    ),
    PieceType.white: new LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        new Color(0xffffffff),
        new Color(0xffe0e0e0),
      ],
    ),
    PieceType.empty: new LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        new Color(0x60ffffff),
        new Color(0x40ffffff),
      ],
    ),
  };

  static const Color backgroundStartColor = const Color(0xb000bfff);
  static const Color backgroundFinishColor = const Color(0xb0ff00ee);
  static const Color thinkingColor = const Color(0xa0ffffff);

  // **** ANIMATIONS ****

  static const Duration thinkingFadeDuration =
      const Duration(milliseconds: 500);

  static const Duration pieceFlipDuration = const Duration(milliseconds: 300);

  // **** SIZES ****

  static const double thinkingSize = 10.0;

  // **** TEXT ****

  static final TextStyle scoreText = new TextStyle(
      fontSize: 50.0,
      fontFamily: 'Roboto',
      decoration: TextDecoration.none,
      color: const Color(0xe0ffffff),
      fontStyle: FontStyle.italic);

  static final TextStyle scoreLabelText = new TextStyle(
      fontSize: 20.0,
      fontFamily: 'Roboto',
      decoration: TextDecoration.none,
      color: const Color(0xa0ffffff),
      fontStyle: FontStyle.normal);

  static final TextStyle resultText = new TextStyle(
      fontSize: 40.0,
      fontFamily: 'Roboto',
      decoration: TextDecoration.none,
      color: const Color(0xe0ffffff),
      fontStyle: FontStyle.italic);

  static final TextStyle buttonText = new TextStyle(
      fontSize: 20.0,
      fontFamily: 'Roboto',
      decoration: TextDecoration.none,
      color: const Color(0xe0ffffff),
      fontStyle: FontStyle.italic);

  // **** BOXES ****

  static final BoxDecoration activePlayerIndicator = new BoxDecoration(
      border: const Border(
          bottom:
              const BorderSide(width: 2.0, color: const Color(0xffffffff))));

  static final BoxDecoration inactivePlayerIndicator = new BoxDecoration(
      border: const Border(
          bottom:
              const BorderSide(width: 2.0, color: const Color(0x00000000))));
}
