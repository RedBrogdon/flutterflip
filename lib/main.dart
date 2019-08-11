// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:flutter/widgets.dart';

import 'game_board.dart';
import 'game_model.dart';
import 'move_finder.dart';
import 'styling.dart';
import 'thinking_indicator.dart';

/// Main function for the app. Turns off the system overlays and locks portrait
/// orientation for a more game-like UI, and then runs the [Widget] tree.
void main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(FlutterFlipApp());
}

/// The App class. Unlike many Flutter apps, this one does not use Material
/// widgets, so there's no [MaterialApp] or [Theme] objects.
class FlutterFlipApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: Color(0xffffffff), // Mandatory background color.
      onGenerateRoute: (settings) {
        return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => GameScreen(),
        );
      },
    );
  }
}

/// The [GameScreen] Widget represents the entire game
/// display, from scores to board state and everything in between.
class GameScreen extends StatefulWidget {
  @override
  State createState() => _GameScreenState();
}

/// State class for [GameScreen].
///
/// The game is modeled as a [Stream] of immutable instances of [GameModel].
/// Each move by the player or CPU results in a new [GameModel], which is
/// sent downstream. [GameScreen] uses a [StreamBuilder] wired up to that stream
/// of models to build out its [Widget] tree.
class _GameScreenState extends State<GameScreen> {
  final StreamController<GameModel> _userMovesController =
      StreamController<GameModel>();
  final StreamController<GameModel> _restartController =
      StreamController<GameModel>();
  Stream<GameModel> _modelStream;

  _GameScreenState() {
    // Below is the combination of streams that controls the flow of the game.
    // There are two streams of models produced by player interaction (either
    // by restarting the game, which produces a brand new game model and sends
    // it downstream, or tapping on one of the board locations to play a piece,
    // which creates a new board model with the result of the move and sends it
    // downstream. The StreamGroup combines these into a single stream, then
    // does a little trick with asyncExpand.
    //
    // The function used in asyncExpand checks to see if it's the CPU's turn
    // (white), and if so creates a [MoveFinder] to look for the best move.
    // it awaits the result, and then creates a new [GameModel] with the result
    // of that move and sends it downstream by yielding it. If it's still the
    // CPU's turn after making that move (which can happen in reversi), this is
    // repeated.
    //
    // The final stream of models that exits the asyncExpand call is a
    // combination of "new game" models, models with the results of player
    // moves, and models with the results of CPU moves. These are fed into the
    // StreamBuilder in [build], and used to create the widgets that comprise
    // the game's display.
    _modelStream = StreamGroup.merge([
      _userMovesController.stream,
      _restartController.stream,
    ]).asyncExpand((model) async* {
      yield model;

      GameModel newModel = model;

      while (newModel.player == PieceType.white) {
        MoveFinder finder = MoveFinder(newModel.board);
        Position move = await finder.findNextMove(newModel.player, 5);
        if (move != null) {
          newModel = newModel.updateForMove(move.x, move.y);
          yield newModel;
        }
      }
    });
  }

  // Thou shalt tidy up thy stream controllers.
  @override
  void dispose() {
    _userMovesController.close();
    _restartController.close();
    super.dispose();
  }

  /// The build method mostly just sets up the StreamBuilder and leaves the
  /// details to _buildWidgets.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GameModel>(
      stream: _modelStream,
      builder: (context, snapshot) {
        return _buildWidgets(
          context,
          snapshot.hasData ? snapshot.data : GameModel(board: GameBoard()),
        );
      },
    );
  }

  // Called when the user taps on the game's board display. If it's the player's
  // turn, this method will attempt to make the move, creating a new GameModel
  // in the process.
  void _attemptUserMove(GameModel model, int x, int y) {
    if (model.player == PieceType.black &&
        model.board.isLegalMove(x, y, model.player)) {
      _userMovesController.add(model.updateForMove(x, y));
    }
  }

  Widget _buildScoreBox(PieceType player, GameModel model) {
    String label = player == PieceType.black ? 'black' : 'white';
    String scoreText = player == PieceType.black
        ? '${model.blackScore}'
        : '${model.whiteScore}';

    return DecoratedBox(
      decoration: (model.player == player)
          ? Styling.activePlayerIndicator
          : Styling.inactivePlayerIndicator,
      child: Column(
        children: <Widget>[
          Text(
            label,
            textAlign: TextAlign.center,
            style: Styling.scoreLabelText,
          ),
          Text(
            scoreText,
            textAlign: TextAlign.center,
            style: Styling.scoreText,
          )
        ],
      ),
    );
  }

  List<Widget> _buildGameBoardDisplay(BuildContext context, GameModel model) {
    final rows = <Widget>[];

    for (int y = 0; y < GameBoard.height; y++) {
      final spots = <Widget>[];

      for (int x = 0; x < GameBoard.width; x++) {
        spots.add(AnimatedContainer(
          duration: Duration(
            milliseconds: 500,
          ),
          margin: EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            gradient:
                Styling.pieceGradients[model.board.getPieceAtLocation(x, y)],
          ),
          child: SizedBox(
            width: 40.0,
            height: 40.0,
            child: GestureDetector(
              onTap: () {
                _attemptUserMove(model, x, y);
              },
            ),
          ),
        ));
      }

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: spots,
      ));
    }

    return rows;
  }

  // Builds out the Widget tree using the most recent GameModel from the stream.
  Widget _buildWidgets(BuildContext context, GameModel model) {
    return Container(
      padding: EdgeInsets.only(top: 30.0, left: 15.0, right: 15.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Styling.backgroundStartColor,
            Styling.backgroundFinishColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 1),
                _buildScoreBox(PieceType.black, model),
                Spacer(flex: 4),
                _buildScoreBox(PieceType.white, model),
                Spacer(flex: 1),
              ],
            ),
            SizedBox(height: 20),
            ThinkingIndicator(
              color: Styling.thinkingColor,
              height: Styling.thinkingSize,
              visible: model.player == PieceType.white,
            ),
            SizedBox(height: 20),
            ..._buildGameBoardDisplay(context, model),
            SizedBox(height: 30),
            if (model.gameIsOver)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    child: Text(
                      model.gameResultString,
                      style: Styling.resultText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _restartController.add(
                        GameModel(board: GameBoard()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xe0ffffff)),
                          borderRadius:
                              BorderRadius.all(const Radius.circular(15.0))),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 15.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          "new game",
                          style: Styling.buttonText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
