// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show SystemChrome;
import 'package:flutter/widgets.dart';
import 'package:async/async.dart';

import 'dart:async';

import 'game_board.dart';
import 'game_model.dart';
import 'maybe_builder.dart';
import 'move_finder.dart';
import 'styling.dart';
import 'thinking_indicator.dart';

/// Main function for the app. Turns off the system overlays for a more game-like
/// UI, and then runs the [Widget] tree.
void main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(new FlutterFlipApp());
}

/// The App class. Unlike most Flutter apps, this one does not use Material
/// Widgets, so there's no [MaterialApp] or [Theme] objects.
class FlutterFlipApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new WidgetsApp(
      color: new Color(0xffffffff), // Mandatory background color.
      onGenerateRoute: (RouteSettings settings) {
        return new PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                new GameScreen());
      },
    );
  }
}

/// The [GameScreen] Widget represents the entire game
/// display, from scores to board state and everything in between.
class GameScreen extends StatefulWidget {
  @override
  State createState() => new _GameScreenState();
}

/// State class for [GameScreen].
///
/// The game is modeled as a [Stream] of immutable instances of [GameModel].
/// Each move by the player or CPU results in a new [GameModel], which is
/// sent downstream. [GameScreen] uses a [StreamBuilder] wired up to that stream
/// of models to build out its [Widget] tree.
class _GameScreenState extends State<GameScreen> {
  final StreamController<GameModel> _userMovesController =
      new StreamController<GameModel>();
  final StreamController<GameModel> _restartController =
      new StreamController<GameModel>();
  Stream<GameModel> _modelStream;

  _GameScreenState() {
    _modelStream = StreamGroup.merge([
      _userMovesController.stream,
      _restartController.stream
    ]).asyncExpand((GameModel model) async* {
      yield model;

      if (model.player == PieceType.white) {
        MoveFinder finder = new MoveFinder(model.board);
        Position move = await finder.findNextMove(model.player, 5);
        if (move != null) {
          yield model.updateForMove(move.x, move.y);
        }
      }
    });
  }

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
    return new StreamBuilder(
        stream: _modelStream,
        builder: (context, snapshot) {
          return _buildWidgets(
              context,
              snapshot.hasData
                  ? snapshot.data
                  : new GameModel(board: new GameBoard()));
        });
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

  // _buildWidgets builds out the Widget tree using the most recent GameModel
  // from the stream.
  Widget _buildWidgets(BuildContext context, GameModel model) {
    return new Container(
        padding: new EdgeInsets.only(top: 30.0, left: 15.0, right: 15.0),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Styling.backgroundStartColor,
              Styling.backgroundFinishColor
            ],
          ),
        ),
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new DecoratedBox(
                      decoration: (model.player == PieceType.black)
                          ? Styling.activePlayerIndicator
                          : Styling.inactivePlayerIndicator,
                      child: new Column(children: <Widget>[
                        new Text("black",
                            textAlign: TextAlign.center,
                            style: Styling.scoreLabelText),
                        new Text("${model.blackScore}",
                            textAlign: TextAlign.center,
                            style: Styling.scoreText)
                      ]),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 200.0),
                      child: new DecoratedBox(
                        decoration: (model.player == PieceType.white)
                            ? Styling.activePlayerIndicator
                            : Styling.inactivePlayerIndicator,
                        child: new Column(
                          children: <Widget>[
                            new Text("white",
                                textAlign: TextAlign.center,
                                style: Styling.scoreLabelText),
                            new Text("${model.whiteScore}",
                                textAlign: TextAlign.center,
                                style: Styling.scoreText),
                          ],
                        ),
                      ),
                    ),
                  ]),
              new Container(
                  margin: new EdgeInsets.only(top: 20.0),
                  height: 10.0,
                  child: new AnimatedOpacity(
                      opacity: (model.player == PieceType.white) ? 1.0 : 0.0,
                      duration: Styling.thinkingFadeDuration,
                      child: new ThinkingIndicator(
                        color: Styling.thinkingColor,
                        size: Styling.thinkingSize,
                      ))),
              new Container(
                  margin: new EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: new Column(
                      children: new List<Widget>.generate(
                          GameBoard.height,
                          (y) => new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: new List<Widget>.generate(
                                  GameBoard.width,
                                  (x) => new AnimatedContainer(
                                      duration: new Duration(
                                        milliseconds: 500,
                                      ),
                                      margin: new EdgeInsets.all(1.0),
                                      decoration: new BoxDecoration(
                                        gradient: Styling.pieceGradients[model
                                            .board
                                            .getPieceAtLocation(x, y)],
                                      ),
                                      child: new SizedBox(
                                          width: 40.0,
                                          height: 40.0,
                                          child: new GestureDetector(onTap: () {
                                            _attemptUserMove(model, x, y);
                                          }))),
                                ),
                              )))),
              new MaybeBuilder(
                  condition: model.gameIsOver,
                  builder: (context) {
                    return new Column(children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.only(
                          top: 30.0,
                          left: 10.0,
                          right: 10.0,
                          bottom: 20.0,
                        ),
                        child: new Text(model.gameResultString,
                            style: Styling.resultText),
                      ),
                      new GestureDetector(
                          onTap: () {
                            _restartController.add(new GameModel(
                              board: new GameBoard(),
                            ));
                          },
                          child: new Container(
                              decoration: new BoxDecoration(
                                  border: new Border.all(
                                      color: const Color(0xe0ffffff)),
                                  borderRadius: new BorderRadius.all(
                                      const Radius.circular(15.0))),
                              padding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 15.0,
                              ),
                              child: new Text(
                                "new game",
                                style: Styling.buttonText,
                              )))
                    ]);
                  })
            ]));
  }
}
