// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show SystemChrome;
import 'package:flutter/widgets.dart';

import 'gameboard.dart';
import 'move_finder.dart';
import 'styling.dart';
import 'thinking_indicator.dart';

void main() {
  debugPaintSizeEnabled = false;
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(new FlutterFlipApp());
}

class FlutterFlipApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new WidgetsApp(
      color: new Color(0xffffffff),
      onGenerateRoute: (RouteSettings settings) {
        return new PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                new GameScreen());
      },
    );
  }
}

class GameScreen extends StatefulWidget {
  GameScreen({Key key}) : super(key: key);

  @override
  _GameScreenState createState() => new _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  GameBoard _currentBoard = new GameBoard();
  PieceType _currentPlayer = PieceType.black;
  bool _moveFinderInProgress = false;
  MoveFinder _finder;
  Animation<double> _thinkingAnimation;
  AnimationController _thinkingController;
  Animation<double> _fadeAnimation;
  AnimationController _fadeController;

  int get _blackScore => _currentBoard.getPieceCount(PieceType.black);

  int get _whiteScore => _currentBoard.getPieceCount(PieceType.white);

  bool get _gameIsOver => (_currentBoard.movesRemaining == 0 ||
      _currentBoard.getMovesForPlayer(_currentPlayer).length == 0);

  String get _gameResultString {
    if (_blackScore > 32) {
      return "Black wins.";
    } else if (_whiteScore > 32) {
      return "White wins.";
    } else {
      return "Tie.";
    }
  }

  BoxDecoration _getPlayerIndicatorDecoration(PieceType player) {
    return (_currentPlayer == player)
        ? Styling.activePlayerIndicator
        : Styling.inactivePlayerIndicator;
  }

  void _attemptUserMove(int x, int y) {
    if (_currentBoard.isLegalMove(x, y, _currentPlayer)) {
      setState(() {
        _currentBoard = _currentBoard.updateForMove(x, y, _currentPlayer);
        if (_currentBoard.movesRemaining > 0 &&
            _currentBoard
                    .getMovesForPlayer(getOpponent(_currentPlayer))
                    .length >
                0) {
          _currentPlayer = getOpponent(_currentPlayer);
          _beginCpuMove();
        }
      });
    }
  }

  void _beginCpuMove() {
    _moveFinderInProgress = true;
    _fadeController.forward();
    _thinkingController.forward();
    _finder = new MoveFinder(_currentBoard, (MoveFinderResult result,
        [Position move]) {
      setState(() {
        _currentBoard =
            _currentBoard.updateForMove(move.x, move.y, _currentPlayer);
        if (_currentBoard.movesRemaining > 0 &&
            _currentBoard
                    .getMovesForPlayer(getOpponent(_currentPlayer))
                    .length ==
                0) {
          _beginCpuMove();
        } else {
          _currentPlayer = getOpponent(_currentPlayer);
          _moveFinderInProgress = false;
          _fadeController.reverse();
        }
      });
    })
      ..findNextMove(_currentPlayer, 5);
  }

  @override
  void initState() {
    super.initState();
    _fadeController = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          // Once the fadeout is complete, there's no need for the "thinking"
          // animation to keep cycling.
          _thinkingController.stop(canceled: false);
        }
      });
    _fadeAnimation = new Tween(begin: 0.0, end: 1.0).animate(
        new CurvedAnimation(parent: _fadeController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });
    _thinkingController = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _thinkingController.reverse();
        if (status == AnimationStatus.dismissed) _thinkingController.forward();
      });
    _thinkingAnimation = new Tween(begin: 0.0, end: 10.0).animate(
        new CurvedAnimation(parent: _thinkingController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });
  }

  List<Widget> _createGameBoardWidgets() {
    return new List<Widget>.generate(
        GameBoard.height,
        (y) => new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: new List<Widget>.generate(
                GameBoard.width,
                (x) => new Container(
                      margin: new EdgeInsets.all(1.0),
                      color: Styling
                          .pieceColors[_currentBoard.getPieceAtLocation(x, y)],
                      child: new SizedBox(
                        width: 40.0,
                        height: 40.0,
                        child: new GestureDetector(
                          onTap: () => _attemptUserMove(x, y),
                        ),
                      ),
                    ))));
  }

  Widget _createEndGameWidget() {
    if (_gameIsOver) {
      return new Column(children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(
            top: 30.0,
            left: 10.0,
            right: 10.0,
            bottom: 20.0,
          ),
          child: new Text(_gameResultString, style: Styling.resultText),
        ),
        new GestureDetector(
            onTap: () {
              setState(() {
                _currentBoard = new GameBoard();
                _currentPlayer = PieceType.black;
              });
            },
            child: new Container(
                decoration: new BoxDecoration(
                    border: new Border.all(color: const Color(0xe0ffffff)),
                    borderRadius:
                        new BorderRadius.all(const Radius.circular(15.0))),
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                child: new Text("new game", style: Styling.buttonText)))
      ]);
    } else {
      return new Container(height: 0.0, width: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: new EdgeInsets.only(top: 60.0, left: 15.0, right: 15.0),
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
                      decoration:
                          _getPlayerIndicatorDecoration(PieceType.black),
                      child: new Column(children: <Widget>[
                        new Text("black",
                            textAlign: TextAlign.center,
                            style: Styling.scoreLabelText),
                        new Text("$_blackScore",
                            textAlign: TextAlign.center,
                            style: Styling.scoreText)
                      ]),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 200.0),
                      child: new DecoratedBox(
                        decoration:
                            _getPlayerIndicatorDecoration(PieceType.white),
                        child: new Column(
                          children: <Widget>[
                            new Text("white",
                                textAlign: TextAlign.center,
                                style: Styling.scoreLabelText),
                            new Text("$_whiteScore",
                                textAlign: TextAlign.center,
                                style: Styling.scoreText),
                          ],
                        ),
                      ),
                    ),
                  ]),
              new Container(
                  margin: new EdgeInsets.only(top: 20.0),
                  height: 20.0,
                  child: new Opacity(
                      opacity: _fadeAnimation.value,
                      child: new ThinkingIndicator(
                          animation: _thinkingAnimation,
                          color: Styling.thinkingIndicatorColor,
                          size: 10.0))),
              new Container(
                margin: new EdgeInsets.only(top: 20.0),
                child: new Column(children: _createGameBoardWidgets()),
              ),
              _createEndGameWidget(),
            ]));
  }

  dispose() {
    _thinkingController.dispose();
    super.dispose();
  }
}
