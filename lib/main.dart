import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show SystemChrome;
import 'gameboard.dart';
import 'move_finder.dart';

void main() {
  debugPaintSizeEnabled = false;
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(new FlutterFlipApp());
}

class FlutterFlipApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      home: new GameScreen(title: 'Flutter Flip'),
    );
  }
}

class GameScreen extends StatefulWidget {
  GameScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GameScreenState createState() => new _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static final Map<PieceType, Color> _colorsForPieces = {
    PieceType.black: new Color(0xff202020),
    PieceType.empty: new Color(0x40ffffff),
    PieceType.white: new Color(0xffffffff)
  };

  static const Color _backgroundStartColor = const Color(0xb000bfff);
  static const Color _backgroundFinishColor = const Color(0xb0ff00ee);

  static final TextStyle _scoreStyle = new TextStyle(
      fontSize: 50.0,
      fontFamily: 'Roboto',
      decoration: TextDecoration.none,
      color: const Color(0xe0ffffff),
      fontStyle: FontStyle.italic);

  static final TextStyle _scoreLabelStyle = new TextStyle(
      fontSize: 20.0,
      fontFamily: 'Roboto',
      decoration: TextDecoration.none,
      color: const Color(0xa0ffffff),
      fontStyle: FontStyle.normal);

  static final TextStyle _resultStyle = new TextStyle(
      fontSize: 40.0,
      fontFamily: 'Roboto',
      decoration: TextDecoration.none,
      color: const Color(0xe0ffffff),
      fontStyle: FontStyle.italic);

  static final TextStyle _buttonTextStyle = new TextStyle(
      fontSize: 20.0,
      fontFamily: 'Roboto',
      decoration: TextDecoration.none,
      color: const Color(0xe0ffffff),
      fontStyle: FontStyle.italic);

  static final List<String> _resultStrings = <String>[
    /* User wins */
    'Lo, I am vanquished.',
    'You\'re cheating, are\'t you? Playing me against myself on another phone?',
    'If I were backed by a cloud service, I totally could have beaten you.',
    /* Tie */
    'Well that was unlikely.',
    'I had one core tied behind my back.',
    'What would you say to a round of sudden death overtime?',
    /* CPU wins */
    'It was probably luck. Play again?',
    'There\'s 3^60 * 2^4 possible board states, so don\'t feel bad.',
    'I have multiple processing cores, and you only have one, so there\'s'
        ' no shame here.',
  ];

  GameBoard _currentBoard = new GameBoard();
  PieceType _currentPlayer = PieceType.black;
  bool _moveFinderInProgress = false;
  MoveFinder _finder;
  int _nextResultStringIndex =
      (new Random().nextInt(_resultStrings.length ~/ 3));

  int get _blackScore => _currentBoard.getPieceCount(PieceType.black);

  int get _whiteScore => _currentBoard.getPieceCount(PieceType.white);

  String _getResultString() {
    if (_blackScore > 32) {
      // User wins
      return _resultStrings[_nextResultStringIndex];
    } else if (_blackScore == 32) {
      // Tie
      return _resultStrings[_nextResultStringIndex + 3];
    } else {
      // CPU wins
      return _resultStrings[_nextResultStringIndex + 6];
    }
  }

  BoxDecoration _getPlayerIndicatorDecoration(PieceType player) {
    if (_currentPlayer == player) {
      return new BoxDecoration(
          border: const Border(
              bottom: const BorderSide(
                  width: 2.0, color: const Color(0xffffffff))));
    } else {
      return new BoxDecoration(
          border: const Border(
              bottom: const BorderSide(
                  width: 2.0, color: const Color(0x00000000))));
    }
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
        }
      });
    })
      ..findNextMove(_currentPlayer, 5);
  }

  List<Widget> _createGameBoardWidgets() {
    List<Widget> widgets = <Widget>[];
    List<int> heightIndices = <int>[0, 1, 2, 3, 4, 5, 6, 7];
    List<int> widthIndices = <int>[0, 1, 2, 3, 4, 5, 6, 7];

    widgets.addAll(heightIndices.map((y) => new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widthIndices
              .map((x) => new Container(
                    margin: new EdgeInsets.all(1.0),
                    color: _colorsForPieces[
                        _currentBoard.getPieceAtLocation(x, y)],
                    child: new SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: new GestureDetector(
                        onTap: () => _attemptUserMove(x, y),
                      ),
                    ),
                  ))
              .toList(),
        )));

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 15.0),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[_backgroundStartColor, _backgroundFinishColor],
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
                            style: _scoreLabelStyle),
                        new Text("$_blackScore",
                            textAlign: TextAlign.center, style: _scoreStyle)
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
                                style: _scoreLabelStyle),
                            new Text("$_whiteScore",
                                textAlign: TextAlign.center,
                                style: _scoreStyle),
                          ],
                        ),
                      ),
                    ),
                  ]),
              new Container(
                margin: new EdgeInsets.only(top: 30.0),
                child: new Column(
                    children: (_currentBoard.movesRemaining > 0 &&
                            (_currentBoard
                                    .getMovesForPlayer(_currentPlayer)
                                    .length >
                                0))
                        ? _createGameBoardWidgets()
                        : <Widget>[
                            new Padding(
                              padding: const EdgeInsets.only(
                                top: 30.0,
                                left: 10.0,
                                right: 10.0,
                                bottom: 50.0,
                              ),
                              child: new Text(_getResultString(),
                                  style: _resultStyle),
                            ),
                            new GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentBoard = new GameBoard();
                                    _currentPlayer = PieceType.black;
                                    _nextResultStringIndex = (new Random()
                                        .nextInt(_resultStrings.length ~/ 3));
                                  });
                                },
                                child: new Container(
                                    decoration: new BoxDecoration(
                                        border: new Border.all(
                                            color: const Color(0xe0ffffff)),
                                        borderRadius: new BorderRadius.all(
                                            const Radius.circular(15.0))),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 15.0),
                                    child: new Text("new game",
                                        style: _buttonTextStyle)))
                          ]),
              ),
            ]));
  }
}
