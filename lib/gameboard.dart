enum PieceType { empty, black, white }

PieceType getOpponent(PieceType player) =>
    (player == PieceType.black) ? PieceType.white : PieceType.black;

class Position {
  Position({this.x, this.y});

  int x;
  int y;
}

class GameBoard {
  static final int height = 8;
  static final int width = 8;
  final _positions = new List<List<PieceType>>(height);
  Map<PieceType, List<Position>> _availableMoveCache = new Map<PieceType, List<Position>>();

  GameBoard() {
    // Load up initial board state
    for (int y = 0; y < width; y++) {
      _positions[y] = new List<PieceType>(height);
      for (int x = 0; x < width; x++) {
        _positions[y][x] = PieceType.empty;
      }
    }

    _positions[3][3] = PieceType.black;
    _positions[3][4] = PieceType.white;
    _positions[4][3] = PieceType.white;
    _positions[4][4] = PieceType.black;
  }

  int get movesRemaining => getPieceCount(PieceType.empty);

  GameBoard.fromGameBoard(GameBoard other) {
    // Copy constructor.
    for (int y = 0; y < height; y++) {
      _positions[y] = new List<PieceType>(width);
      for (int x = 0; x < width; x++) {
        _positions[y][x] = other._positions[y][x];
      }
    }
  }

  PieceType getPieceAtLocation(int x, int y) {
    assert(x >= 0 && x < width);
    assert(y >= 0 && y < height);
    return _positions[y][x];
  }

  int getPieceCount(PieceType pieceType) {
    int count = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (_positions[y][x] == pieceType) {
          count++;
        }
      }
    }
    return count;
  }

  List<Position> getMovesForPlayer(PieceType player) {
    assert(player != PieceType.empty);

    if (_availableMoveCache.containsKey(player)) {
      return _availableMoveCache[player];
    }

    List<Position> legalMoves = <Position>[];
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < width; y++) {
        if (isLegalMove(x, y, player)) {
          legalMoves.add(new Position(x: x, y: y));
        }
      }
    }

    _availableMoveCache[player] = legalMoves;
    return legalMoves;
  }

  GameBoard updateForMove(int x, int y, PieceType player) {
    assert(player != PieceType.empty);
    assert(isLegalMove(x, y, player));
    GameBoard newBoard = new GameBoard.fromGameBoard(this);
    newBoard._positions[y][x] = player;

    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        newBoard._traversePath(x, y, dx, dy, player, true);
      }
    }

    return newBoard;
  }

  bool _traversePath(
      int x, int y, int dx, int dy, PieceType player, bool flip) {
    bool foundOpponent = false;
    int curX = x + dx;
    int curY = y + dy;

    while (curX >= 0 && curX < width && curY >= 0 && curY < height) {
      if (_positions[curY][curX] == PieceType.empty) {
        // This path led to an empty spot rather than a legal move.
        return false;
      } else if (_positions[curY][curX] == getOpponent(player)) {
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
            _positions[curY][curX] = player;
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

  bool isLegalMove(int x, int y, PieceType player) {
    assert(player != PieceType.empty);
    assert(x >= 0 && x < width);
    assert(y >= 0 && y < height);

    // It's occupied, yo.
    if (_positions[y][x] != PieceType.empty) return false;

    // Try each of the eight cardinal directions, looking for a row of opposing
    // pieces to flip.
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        if (_traversePath(x, y, dx, dy, player, false)) return true;
      }
    }

    // No flippable opponent pieces were found in any directions. This is not a
    // legal move.
    return false;
  }
}
