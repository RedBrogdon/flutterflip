# flutterflip

[![Build Status](https://github.com/RedBrogdon/flutterflip/workflows/CI/badge.svg)](https://github.com/RedBrogdon/flutterflip/actions?workflow=CI)

A single-player reversi clone built with [Flutter](https://flutter.dev),
which compiles for Android, iOS, web, macOS, Windows, and Linux.

The user plays as black, and the CPU will make moves as white in response.
The move search only goes 4-5 plies ahead, so it's not that sophisticated,
but puts up a reasonable fight.

![Screenshot](https://i.imgur.com/A96Hdcr.png)

## Why this exists

This was written as an exercise to help me ramp up on Flutter, back when I
joined the team in the spring of 2018, and it's intended to be an open
source example. The tech used includes:

* [Streams](https://www.dartlang.org/tutorials/language/streams)!
* Dart [Isolates](https://api.dart.dev/stable/2.18.0/dart-isolate/dart-isolate-library.html)
* Implicit animations like [AnimatedOpacity](https://api.flutter.dev/flutter/widgets/AnimatedOpacity-class.html)
  and [AnimatedContainer](https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html).

If you spot a bug, feel free to file an issue report. You should also feel
free to fork the repo and redo the UI into something snazzier. If you do,
posta picture on Twitter!
