// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:isolate';

import 'game_board.dart';
import 'game_board_scorer.dart';

enum MoveFinderResult { moveFound, noPossibleMove }
enum MoveFinderIsolateState { idle, loading, running }

/// This class holds all the data needed by the Dart isolate that's responsible
/// for searching the tree of possible moves.
class MoveFinderIsolateArguments {
  MoveFinderIsolateArguments(
      this.board, this.player, this.numPlies, this.sendPort);

  final GameBoard board;
  final PieceType player;
  final int numPlies;
  final SendPort sendPort;
}

/// This is the data the isolate sends back once it's finished looking for the
/// best available move.
class MoveFinderIsolateOutput {
  final MoveFinderResult result;
  final Position move;

  const MoveFinderIsolateOutput(this.result, [this.move]);
}

/// A move and its score. Used by the minimax algorithm.
class ScoredMove {
  final int score;
  final Position move;

  const ScoredMove(this.score, this.move);
}

/// The [MoveFinder] class encapsulates an isolate that will perform a minimax
/// for the best available move on a [GameBoard] using a [GameBoardScorer] to
/// provide the heuristic.
class MoveFinder {
  final GameBoard initialBoard;
  final Completer<Position> completer = new Completer<Position>();

  MoveFinderIsolateState _state = MoveFinderIsolateState.idle;

  bool get isRunning => _state != MoveFinderIsolateState.idle;

  final ReceivePort _receivePort;
  Isolate _isolate;

  MoveFinder(this.initialBoard)
      : assert(initialBoard != null),
        _receivePort = new ReceivePort() {
    _receivePort.listen(_handleMessage);
  }

  /// Searches the tree of possible moves on [initialBoard] to a depth of
  /// [numPlies], looking for the best possible move for [player]. Because the
  /// actual work is done in an isolate, a [Future] is used as the return value.
  Future<Position> findNextMove(PieceType player, int numPlies) {
    if (!completer.isCompleted && !isRunning) {
      final MoveFinderIsolateArguments args = new MoveFinderIsolateArguments(
          initialBoard, player, numPlies, _receivePort.sendPort);

      _state = MoveFinderIsolateState.loading;

      Isolate.spawn(_isolateMain, args).then((Isolate isolate) {
        if (!isRunning) {
          isolate.kill(priority: Isolate.immediate);
        } else {
          _state = MoveFinderIsolateState.running;
          _isolate = isolate;
        }
      });
    }

    return completer.future;
  }

  // This method is responsible for receiving the one and only message the
  // isolate will send back, and using it to complete the Future returned by
  // [findNextMove].
  void _handleMessage(dynamic message) {
    if (message is MoveFinderIsolateOutput) {
      _state = MoveFinderIsolateState.idle;
      _isolate = null;
      if (message.result == MoveFinderResult.moveFound) {
        completer.complete(message.move);
      } else {
        completer.completeError(null);
      }
    }
  }

  // This is a recursive implementation of minimax, an algorithm so old it has
  // its own Wikipedia page: https://en.wikipedia.org/wiki/Minimax.
  static ScoredMove _isolateRecursor(GameBoard board, PieceType scoringPlayer,
      PieceType player, int pliesRemaining) {
    List<Position> availableMoves = board.getMovesForPlayer(player);

    if (availableMoves.length == 0) {
      return new ScoredMove(0, null);
    }

    int score = (scoringPlayer == player)
        ? GameBoardScorer.minScore
        : GameBoardScorer.maxScore;
    ScoredMove bestMove;

    for (int i = 0; i < availableMoves.length; i++) {
      GameBoard newBoard =
          board.updateForMove(availableMoves[i].x, availableMoves[i].y, player);
      if (pliesRemaining > 0 &&
          newBoard.getMovesForPlayer(getOpponent(player)).length > 0) {
        // Opponent has next turn.
        score = _isolateRecursor(newBoard, scoringPlayer, getOpponent(player),
                pliesRemaining - 1)
            .score;
      } else if (pliesRemaining > 0 &&
          newBoard.getMovesForPlayer(player).length > 0) {
        // Opponent has no moves; player gets another turn.
        score = _isolateRecursor(
                newBoard, scoringPlayer, player, pliesRemaining - 1)
            .score;
      } else {
        // Game is over or the search has reached maximum depth.
        score = new GameBoardScorer(newBoard).getScore(scoringPlayer);
      }

      if (bestMove == null ||
          (score > bestMove.score && scoringPlayer == player) ||
          (score < bestMove.score && scoringPlayer != player)) {
        bestMove = new ScoredMove(
            score, new Position(availableMoves[i].x, availableMoves[i].y));
      }
    }

    return bestMove;
  }

  // The method the isolate starts on. It's required to be static.
  static void _isolateMain(MoveFinderIsolateArguments args) {
    ScoredMove bestMove = _isolateRecursor(
        args.board, args.player, args.player, args.numPlies - 1);

    if (bestMove.move != null) {
      args.sendPort.send(new MoveFinderIsolateOutput(
          MoveFinderResult.moveFound, bestMove.move));
    } else {
      args.sendPort
          .send(new MoveFinderIsolateOutput(MoveFinderResult.noPossibleMove));
    }
  }
}
