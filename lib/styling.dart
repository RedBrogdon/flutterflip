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
    PieceType.black: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xff101010),
        Color(0xff303030),
      ],
    ),
    PieceType.white: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xffffffff),
        Color(0xffe0e0e0),
      ],
    ),
    PieceType.empty: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0x60ffffff),
        Color(0x40ffffff),
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

  static final TextStyle scoreText = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Roboto',
    color: const Color(0xe0ffffff),
    fontStyle: FontStyle.italic,
  );

  static final TextStyle scoreLabelText = TextStyle(
    fontSize: 20.0,
    fontFamily: 'Roboto',
    color: const Color(0xa0ffffff),
    fontStyle: FontStyle.normal,
  );

  static final TextStyle resultText = TextStyle(
    fontSize: 40.0,
    fontFamily: 'Roboto',
    color: const Color(0xe0ffffff),
    fontStyle: FontStyle.italic,
  );

  static final TextStyle buttonText = TextStyle(
    fontSize: 20.0,
    fontFamily: 'Roboto',
    color: const Color(0xe0ffffff),
    fontStyle: FontStyle.italic,
  );

  // **** BOXES ****

  static final BoxDecoration activePlayerIndicator = BoxDecoration(
    border: const Border(
      bottom: const BorderSide(
        width: 2.0,
        color: const Color(0xffffffff),
      ),
    ),
  );

  static final BoxDecoration inactivePlayerIndicator = BoxDecoration(
    border: const Border(
      bottom: const BorderSide(
        width: 2.0,
        color: const Color(0x00000000),
      ),
    ),
  );
}
