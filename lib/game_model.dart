// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'game_board.dart';

/// A model representing the state of a game of reversi. It's a board and the
/// player who's next to go, essentially.
class GameModel {
  late final GameBoard board;
  final PieceType player;

  GameModel({
    required this.board,
    this.player = PieceType.black,
  });

  int get blackScore => board.getPieceCount(PieceType.black);

  int get whiteScore => board.getPieceCount(PieceType.white);

  bool get gameIsOver => (board.getMovesForPlayer(player).isEmpty);

  String get gameResultString {
    if (blackScore > whiteScore) {
      return 'Black wins.';
    } else if (whiteScore > blackScore) {
      return 'White wins.';
    } else {
      return 'Tie.';
    }
  }

  /// Attempts to create a new instance of GameModel using the coordinates
  /// provided as the current player's move. If successful, a new GameModel is
  /// returned. If unsuccessful, null is returned.
  GameModel updateForMove(int x, int y) {
    if (!board.isLegalMove(x, y, player)) {
      throw Exception('Attempted to update board with an illegal move.');
    }

    final newBoard = board.updateForMove(x, y, player);
    PieceType nextPlayer;

    if (newBoard.getMovesForPlayer(getOpponent(player)).isNotEmpty) {
      nextPlayer = getOpponent(player);
    } else if (newBoard.getMovesForPlayer(player).isNotEmpty) {
      nextPlayer = player;
    } else {
      nextPlayer = PieceType.empty;
    }

    return GameModel(board: newBoard, player: nextPlayer);
  }
}
