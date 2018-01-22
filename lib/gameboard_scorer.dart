import 'gameboard.dart';

class GameBoardScorer {
  // Values for each position on the board.
  static const List<List<int>> positionValues = const [
    const <int>[1000, 100, 100, 100, 100, 100, 100, 1000],
    const <int>[100, 1, 1, 1, 1, 1, 1, 100],
    const <int>[100, 1, 50, 50, 50, 50, 1, 100],
    const <int>[100, 1, 50, 1, 1, 50, 1, 100],
    const <int>[100, 1, 50, 1, 1, 50, 1, 100],
    const <int>[100, 1, 50, 50, 50, 50, 1, 100],
    const <int>[100, 1, 1, 1, 1, 1, 1, 100],
    const <int>[1000, 100, 100, 100, 100, 100, 100, 1000],
  ];

  GameBoard _board;

  GameBoardScorer(GameBoard board) {
    _board = board;
  }

  int getScore(PieceType player) {
    assert(player != PieceType.empty);
    return 0;
  }
}
