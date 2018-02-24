// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'game_board.dart';

class GameBoardScorer {
  // Values for each position on the board.
  static const List<List<int>> _positionValues = const [
    const <int>[10000, -1000, 100, 100, 100, 100, -1000, 10000],
    const <int>[-1000, -1000, 1, 1, 1, 1, -1000, -1000],
    const <int>[100, 1, 50, 50, 50, 50, 1, 100],
    const <int>[100, 1, 50, 1, 1, 50, 1, 100],
    const <int>[100, 1, 50, 1, 1, 50, 1, 100],
    const <int>[100, 1, 50, 50, 50, 50, 1, 100],
    const <int>[-1000, -1000, 1, 1, 1, 1, -1000, -1000],
    const <int>[10000, -1000, 100, 100, 100, 100, -1000, 10000],
  ];

  /// Maximum and minimum values for scores, which are used in the minimax
  /// algorithm in MoveFinder.
  static const maxScore = 1000 * 1000 * 1000;
  static const minScore = -1 * maxScore;

  GameBoard _board;

  GameBoardScorer(GameBoard board) {
    _board = board;
  }

  /// Returns the score of the board, as determined by what pieces are in place,
  /// and how valuable their locations are. This is a very simple scoring
  /// heuristic, but it's surprisingly effective.
  int getScore(PieceType player) {
    assert(player != PieceType.empty);
    PieceType opponent = getOpponent(player);
    int score = 0;

    if (_board.getMovesForPlayer(PieceType.black).length == 0 &&
        _board.getMovesForPlayer(PieceType.white).length == 0) {
      // Game is over.
      int playerCount = _board.getPieceCount(player);
      int opponentCount = _board.getPieceCount(getOpponent(player));

      if (playerCount > opponentCount) {
        return maxScore;
      } else if (playerCount < opponentCount) {
        return minScore;
      } else {
        return 0;
      }
    }

    for (int y = 0; y < GameBoard.height; y++) {
      for (int x = 0; x < GameBoard.width; x++) {
        if (_board.getPieceAtLocation(x, y) == player) {
          score += _positionValues[y][x];
        } else if (_board.getPieceAtLocation(x, y) == opponent) {
          score -= _positionValues[y][x];
        }
      }
    }

    return score;
  }
}
