// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'game_board.dart';

/// A model representing the state of a game of reversi. It's a board and the
/// player who's next to go, essentially.
class GameModel {
  final GameBoard board;
  final PieceType player;

  GameModel({this.board, this.player: PieceType.black}) : assert(board != null);

  int get blackScore => board.getPieceCount(PieceType.black);

  int get whiteScore => board.getPieceCount(PieceType.white);

  bool get gameIsOver => (board.getMovesForPlayer(player).length == 0);

  String get gameResultString {
    if (blackScore > whiteScore) {
      return "Black wins.";
    } else if (whiteScore > blackScore) {
      return "White wins.";
    } else {
      return "Tie.";
    }
  }

  /// Attempts to create a new instance of GameModel using the coordinates
  /// provided as the current player's move. If successful, a new GameModel is
  /// returned. If unsuccessful, null is returned.
  ///
  /// This is another method that probably shouldn't live where it does, but I
  /// don't have a better idea for where to put it.
  GameModel updateForMove(int x, int y) {
    if (!board.isLegalMove(x, y, player)) {
      return null;
    }

    GameBoard newBoard = board.updateForMove(x, y, player);
    PieceType nextPlayer;

    if (newBoard.getMovesForPlayer(getOpponent(player)).length > 0) {
      nextPlayer = getOpponent(player);
    } else if (newBoard.getMovesForPlayer(player).length > 0) {
      nextPlayer = player;
    } else {
      nextPlayer = PieceType.empty;
    }

    return GameModel(board: newBoard, player: nextPlayer);
  }
}
