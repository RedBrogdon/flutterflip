import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show SystemChrome;
import 'package:flutter/widgets.dart';

import 'gameboard.dart';
import 'move_finder.dart';
import 'styling.dart';

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
  Animation<double> _thinkingAnimation;
  AnimationController _thinkingController;
  Animation<double> _fadeAnimation;
  AnimationController _fadeController;

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
    _fadeController.forward();
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

  List<Widget> _createGameBoardWidgets() {
    List<Widget> widgets = <Widget>[];
    List<int> heightIndices = <int>[0, 1, 2, 3, 4, 5, 6, 7];
    List<int> widthIndices = <int>[0, 1, 2, 3, 4, 5, 6, 7];

    widgets.addAll(heightIndices.map((y) => new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widthIndices
              .map((x) => new Container(
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
                  ))
              .toList(),
        )));

    return widgets;
  }

  initState() {
    super.initState();
    _thinkingController = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _thinkingController.reverse();
        if (status == AnimationStatus.dismissed) _thinkingController.forward();
      });
    _thinkingAnimation = new Tween(begin: 0.0, end: 20.0).animate(
        new CurvedAnimation(parent: _thinkingController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });
    _fadeController = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = new Tween(begin: 0.0, end: 1.0).animate(
        new CurvedAnimation(parent: _fadeController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });
    _thinkingController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: new EdgeInsets.symmetric(vertical: 60.0, horizontal: 15.0),
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
                      child: new MoveSearchIndicator(
                          animation: _thinkingAnimation,
                          color: new Color(0xa0ffffff),
                          size: 10.0))),
              new Container(
                margin: new EdgeInsets.only(top: 20.0),
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
                                  style: Styling.resultText),
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
                                        style: Styling.buttonText)))
                          ]),
              ),
            ]));
  }

  dispose() {
    _thinkingController.dispose();
    super.dispose();
  }
}

class MoveSearchIndicator extends AnimatedWidget {
  MoveSearchIndicator(
      {Key key, Animation<double> animation, this.color, this.size})
      : super(key: key, listenable: animation);

  final Color color;
  final double size;

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return new Center(
      child: new SizedBox(
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Padding(
                padding: new EdgeInsets.only(right: animation.value),
                child: new Container(
                    width: this.size,
                    height: this.size,
                    decoration: new BoxDecoration(
                      border: new Border.all(color: this.color, width: 2.0),
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(5.0)),
                    ))),
            new Padding(
                padding: new EdgeInsets.only(right: animation.value),
                child: new Container(
                    width: this.size,
                    height: this.size,
                    decoration: new BoxDecoration(
                      border: new Border.all(color: this.color, width: 2.0),
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(5.0)),
                    ))),
            new Padding(
                padding: new EdgeInsets.only(right: animation.value),
                child: new Container(
                    width: this.size,
                    height: this.size,
                    decoration: new BoxDecoration(
                      border: new Border.all(color: this.color, width: 2.0),
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(5.0)),
                    ))),
            new Padding(
                padding: new EdgeInsets.only(right: animation.value),
                child: new Container(
                    width: this.size,
                    height: this.size,
                    decoration: new BoxDecoration(
                      border: new Border.all(color: this.color, width: 2.0),
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(5.0)),
                    ))),
            new Container(
                width: this.size,
                height: this.size,
                decoration: new BoxDecoration(
                  border: new Border.all(color: this.color, width: 2.0),
                  borderRadius:
                      new BorderRadius.all(const Radius.circular(5.0)),
                )),
          ],
        ),
      ),
    );
  }
}
