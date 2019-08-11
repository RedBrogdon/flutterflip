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

  static const Map<PieceType, LinearGradient> pieceGradients = {
    PieceType.black: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xff101010),
        Color(0xff303030),
      ],
    ),
    PieceType.white: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xffffffff),
        Color(0xffe0e0e0),
      ],
    ),
    PieceType.empty: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x60ffffff),
        Color(0x40ffffff),
      ],
    ),
  };

  static const backgroundStartColor = Color(0xb000bfff);
  static const backgroundFinishColor = Color(0xb0ff00ee);
  static const thinkingColor = Color(0xa0ffffff);

  // **** ANIMATIONS ****

  static const Duration thinkingFadeDuration = Duration(milliseconds: 500);

  static const pieceFlipDuration = Duration(milliseconds: 300);

  // **** SIZES ****

  static const thinkingSize = 10.0;

  // **** TEXT ****

  static const scoreText = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Roboto',
    color: Color(0xe0ffffff),
    fontStyle: FontStyle.italic,
  );

  static const scoreLabelText = TextStyle(
    fontSize: 20.0,
    fontFamily: 'Roboto',
    color: Color(0xa0ffffff),
    fontStyle: FontStyle.normal,
  );

  static const resultText = TextStyle(
    fontSize: 40.0,
    fontFamily: 'Roboto',
    color: Color(0xe0ffffff),
    fontStyle: FontStyle.italic,
  );

  static const buttonText = TextStyle(
    fontSize: 20.0,
    fontFamily: 'Roboto',
    color: Color(0xe0ffffff),
    fontStyle: FontStyle.italic,
  );

  // **** BOXES ****

  static const activePlayerIndicator = BoxDecoration(
    border: Border(
      bottom: BorderSide(
        width: 2.0,
        color: Color(0xffffffff),
      ),
    ),
  );

  static const inactivePlayerIndicator = BoxDecoration(
    border: Border(
      bottom: BorderSide(
        width: 2.0,
        color: Color(0x00000000),
      ),
    ),
  );
}
