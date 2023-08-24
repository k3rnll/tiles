import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tiles/game.dart';

void main() {
  final tileGame = TileGame();
  runApp(GameWidget(game: tileGame));
}
