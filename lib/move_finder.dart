import 'gameboard.dart';
import 'gameboard_scorer.dart';

import 'dart:isolate';
import 'dart:math';

enum MoveFinderResult { moveFound, noPossibleMove }
enum MoveFinderIsolateState { idle, loading, running }

class MoveFinderIsolateArguments {
  MoveFinderIsolateArguments(
      this.board, this.player, this.numPlies, this.sendPort);

  final GameBoard board;
  final PieceType player;
  final int numPlies;
  final SendPort sendPort;
}

class MoveFinderIsolateOutput {
  MoveFinderIsolateOutput(this.result, [this.move]);

  final MoveFinderResult result;
  final Position move;
}

typedef void MoveFinderCompletionListener(MoveFinderResult result,
    [Position move]);

class MoveFinder {
  final GameBoard initialBoard;
  final MoveFinderCompletionListener listener;

  MoveFinderIsolateState _state = MoveFinderIsolateState.idle;

  MoveFinderIsolateState get state => _state;

  bool get isRunning => _state != MoveFinderIsolateState.idle;

  final ReceivePort _receivePort;
  Isolate _isolate;

  MoveFinder(this.initialBoard, this.listener)
      : assert(listener != null),
        assert(initialBoard != null),
        _receivePort = new ReceivePort() {
    _receivePort.listen(_handleMessage);
  }

  void findNextMove(PieceType player, int numPlies) {
    if (!isRunning) {
      final MoveFinderIsolateArguments args = new MoveFinderIsolateArguments(
          initialBoard, player, numPlies, _receivePort.sendPort);

      _state = MoveFinderIsolateState.loading;

      Isolate.spawn(_isolateMain, args).then<Null>((Isolate isolate) {
        if (!isRunning) {
          isolate.kill(priority: Isolate.IMMEDIATE);
        } else {
          _state = MoveFinderIsolateState.running;
          _isolate = isolate;
        }
      });
    }
  }

  void cancelSearch() {
    if (isRunning) {
      _state = MoveFinderIsolateState.idle;
      if (_isolate != null) {
        _isolate.kill(priority: Isolate.IMMEDIATE);
        _isolate = null;
      }
    }
  }

  void _handleMessage(dynamic message) {
    if (message is MoveFinderIsolateOutput) {
      _state = MoveFinderIsolateState.idle;
      _isolate = null;
      listener(message.result, message.move);
    }
  }

  static void _isolateMain(MoveFinderIsolateArguments args) {
    List<Position> moves = args.board.getMovesForPlayer(args.player);
    if (moves.length == 0) {
      args.sendPort.send(
          new MoveFinderIsolateOutput(MoveFinderResult.noPossibleMove, null));
    } else {
      args.sendPort.send(new MoveFinderIsolateOutput(MoveFinderResult.moveFound,
          moves[(new Random()).nextInt(moves.length)]));
    }
  }
}

class MoveFinderIsolate {}
