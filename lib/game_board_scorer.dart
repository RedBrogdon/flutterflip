// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'game_board.dart';

class GameBoardScorer {
  // Values for each position on the board.
  static const _positionValues = [
    [10000, -1000, 100, 100, 100, 100, -1000, 10000],
    [-1000, -1000, 1, 1, 1, 1, -1000, -1000],
    [100, 1, 50, 50, 50, 50, 1, 100],
    [100, 1, 50, 1, 1, 50, 1, 100],
    [100, 1, 50, 1, 1, 50, 1, 100],
    [100, 1, 50, 50, 50, 50, 1, 100],
    [-1000, -1000, 1, 1, 1, 1, -1000, -1000],
    [10000, -1000, 100, 100, 100, 100, -1000, 10000],
  ];

  /// Maximum and minimum values for scores, which are used in the minimax
  /// algorithm in [MoveFinder].
  static const maxScore = 1000 * 1000 * 1000;
  static const minScore = -1 * maxScore;

  final GameBoard board;

  GameBoardScorer(this.board);

  /// Returns the score of the board, as determined by what pieces are in place,
  /// and how valuable their locations are. This is a very simple scoring
  /// heuristic, but it's surprisingly effective.
  int getScore(PieceType player) {
    assert(player != PieceType.empty);
    var opponent = getOpponent(player);
    var score = 0;

    if (board.getMovesForPlayer(PieceType.black).isEmpty &&
        board.getMovesForPlayer(PieceType.white).isEmpty) {
      // Game is over.
      var playerCount = board.getPieceCount(player);
      var opponentCount = board.getPieceCount(getOpponent(player));

      if (playerCount > opponentCount) {
        return maxScore;
      } else if (playerCount < opponentCount) {
        return minScore;
      } else {
        return 0;
      }
    }

    for (var y = 0; y < GameBoard.height; y++) {
      for (var x = 0; x < GameBoard.width; x++) {
        if (board.getPieceAtLocation(x, y) == player) {
          score += _positionValues[y][x];
        } else if (board.getPieceAtLocation(x, y) == opponent) {
          score -= _positionValues[y][x];
        }
      }
    }

    return score;
  }
}
