// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

enum PieceType {
  empty,
  black,
  white,
}

/// This method flips a black piece to a white one, and vice versa. I'm still
/// unsure about having it as a global function, but don't know where else to
/// put it.
PieceType getOpponent(PieceType player) =>
    (player == PieceType.black) ? PieceType.white : PieceType.black;

/// A position on the reversi board. Just an [x] and [y] coordinate pair.
class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);
}

/// An immutable representation of a reversi game's board.
class GameBoard {
  static const height = 8;
  static const width = 8;
  final List<List<PieceType>> rows;

  // Because calculating out all the available moves for a player can be
  // expensive, they're cached here.
  final _availableMoveCache = <PieceType, List<Position>>{};

  /// Default constructor, which creates a board with pieces in starting
  /// position.
  GameBoard() : rows = _emptyBoard;

  /// Copy constructor.
  GameBoard.fromGameBoard(GameBoard other)
      : rows = List.generate(height, (i) => List.from(other.rows[i]));

  /// Retrieves the type of piece at a location on the game board.
  PieceType getPieceAtLocation(int x, int y) {
    assert(x >= 0 && x < width);
    assert(y >= 0 && y < height);
    return rows[y][x];
  }

  /// Gets the total number of pieces of a particular type.
  int getPieceCount(PieceType pieceType) {
    return rows.fold(
      0,
      (s, e) => s + e.where((e) => e == pieceType).length,
    );
  }

  /// Calculates the list of available moves on this board for a player. These
  /// moves are calculated for the first call and cached for any subsequent
  /// ones.
  List<Position> getMovesForPlayer(PieceType player) {
    if (player == PieceType.empty) {
      return [];
    }

    if (_availableMoveCache.containsKey(player)) {
      return _availableMoveCache[player]!;
    }

    final legalMoves = <Position>[];
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < width; y++) {
        if (isLegalMove(x, y, player)) {
          legalMoves.add(Position(x, y));
        }
      }
    }

    _availableMoveCache[player] = legalMoves;
    return legalMoves;
  }

  /// Returns a new GameBoard instance representing the state this one would
  /// have after [player] puts a piece at [x],[y]. This method does not check if
  /// the move was legal, and will blindly trust its input.
  GameBoard updateForMove(int x, int y, PieceType player) {
    assert(player != PieceType.empty);
    final newBoard = GameBoard.fromGameBoard(this);

    if (!isLegalMove(x, y, player)) {
      return newBoard;
    }

    newBoard.rows[y][x] = player;

    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        newBoard._traversePath(x, y, dx, dy, player, true);
      }
    }

    return newBoard;
  }

  /// Returns true if it would be a legal move for [player] to put a piece down
  /// at [x],[y].
  bool isLegalMove(int x, int y, PieceType player) {
    assert(player != PieceType.empty);
    assert(x >= 0 && x < width);
    assert(y >= 0 && y < height);

    // It's occupied, yo. No can do.
    if (rows[y][x] != PieceType.empty) return false;

    // Try each of the eight cardinal directions, looking for a row of opposing
    // pieces to flip.
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        if (_traversePath(x, y, dx, dy, player, false)) return true;
      }
    }

    // No flippable opponent pieces were found in any directions. This is not a
    // legal move.
    return false;
  }

  // This method walks the board in one of eight cardinal directions (determined
  // by the [dx] and [dy] parameters) beginning at [x],[y], and attempts to
  // determine if a move at [x],[y] by [player] would result in pieces getting
  // flipped. If so, the method returns true, otherwise false. If [flip] is set
  // to true, the pieces are flipped in place to their new colors before the
  // method returns.
  bool _traversePath(
      int x, int y, int dx, int dy, PieceType player, bool flip) {
    var foundOpponent = false;
    var curX = x + dx;
    var curY = y + dy;

    while (curX >= 0 && curX < width && curY >= 0 && curY < height) {
      if (rows[curY][curX] == PieceType.empty) {
        // This path led to an empty spot rather than a legal move.
        return false;
      } else if (rows[curY][curX] == getOpponent(player)) {
        // Update flag and keep going, hoping to hit one of player's pieces.
        foundOpponent = true;
      } else if (foundOpponent) {
        // Found opposing pieces and then one of player's afterward. This is
        // a legal move.
        if (flip) {
          // Backtrack, flipping pieces to player's color.
          while (curX != x || curY != y) {
            curX -= dx;
            curY -= dy;
            rows[curY][curX] = player;
          }
        }
        return true;
      } else {
        // Found one of player's pieces, but no opposing pieces.
        return false;
      }

      curX += dx;
      curY += dy;
    }

    return false;
  }
}

const _emptyBoard = [
  [
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
  ],
  [
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
  ],
  [
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
  ],
  [
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.black,
    PieceType.white,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
  ],
  [
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.white,
    PieceType.black,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
  ],
  [
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
  ],
  [
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
  ],
  [
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
    PieceType.empty,
  ],
];
