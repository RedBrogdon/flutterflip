import 'package:flutter/widgets.dart';
import 'gameboard.dart';

// The Theme class is part of Flutter's Material Design package, which this game
// doesn't use. Instead, this static class is used as a convenient spot to hold
// constants for colors, text styles, and so on.
//
// While a larger app would need something more sophisticated, for a simple,
// one-screen game, this gets the job done just fine.
abstract class Styling {
  static final Map<PieceType, Color> pieceColors = {
    PieceType.black: new Color(0xff202020),
    PieceType.empty: new Color(0x40ffffff),
    PieceType.white: new Color(0xffffffff)
  };

  static const Color backgroundStartColor = const Color(0xb000bfff);
  static const Color backgroundFinishColor = const Color(0xb0ff00ee);

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

  static final TextStyle resultText= new TextStyle(
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
}