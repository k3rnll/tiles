/*

класс для кнопок

перезапустить игру
поменять размер сетки
показывать обратный таймер при learningPause

вид просто полоской как апбар сверху или снизу
три поля


 */

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:tiles/game.dart';

class Hud extends PositionComponent with HasGameRef<TileGame> {

  @override
  Future<void>? onLoad() async {
    super.size = Vector2((game.size.x - 1), 50);
    super.position = (Vector2(0, game.cam.viewport.size.y));
    super.anchor = Anchor.topLeft;

    add(RestartButton());
    add(CountDown());
    add(GridSizeButtonMinus());
    add(GridSize());
    add(GridSizeButtonPlus());
    return super.onLoad();
  }

  @override
  bool get debugMode => false;
}

class CountDown extends TextComponent with HasGameRef<TileGame> {
  @override
  Future<void>? onLoad() async {
    super.position = Vector2(game.size.x / 2, 25);
    super.anchor = Anchor.center;
    super.text = "${game.timeToRememberSeconds ~/ 1}";
    return super.onLoad();
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    super.text = game.isGameRunning ? "" : "${game.timeToRememberSeconds ~/ 1}";
  }
  @override
  bool get debugMode => false;
}

class RestartButton extends TextComponent with HasGameRef<TileGame>, TapCallbacks {
  @override
  Future<void>? onLoad() async {
    super.position = Vector2(25, 25);
    super.anchor = Anchor.centerLeft;
    super.text = "new game";
    return super.onLoad();
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.startNewGame();
    print("new game button");
  }
  @override
  bool get debugMode => false;
}

class GridSizeButtonPlus extends PositionComponent with HasGameRef<TileGame>, TapCallbacks {
  @override
  Future<void>? onLoad() async {
    super.size = Vector2(game.size.x / 4, 40);
    super.position = Vector2(game.size.x, 25);
    super.anchor = Anchor.centerRight;
    add(TextComponent(text: "+", position: Vector2(game.size.x / 8, 20), anchor: Anchor.centerRight));
    return super.onLoad();
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }
  @override
  void onTapDown(TapDownEvent event) {
    game.incrementGridSize();
    print("grid plus button");
  }
  @override
  bool get debugMode => false;
}

class GridSize extends TextComponent with HasGameRef<TileGame> {
  @override
  Future<void>? onLoad() async {
    super.position = Vector2((game.size.x / 4)*3, 25);
    super.anchor = Anchor.center;
    return super.onLoad();
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    super.text = "${game.getNewGridSize()}";
  }
  @override
  bool get debugMode => false;
}

class GridSizeButtonMinus extends PositionComponent with HasGameRef<TileGame>, TapCallbacks {
  @override
  Future<void>? onLoad() async {
    super.size = Vector2(game.size.x / 4, 40);
    super.position = Vector2((game.size.x / 2), 25);
    super.anchor = Anchor.centerLeft;
    add(TextComponent(text: "-", position: Vector2(game.size.x / 8, 20), anchor: Anchor.centerLeft));
    return super.onLoad();
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.decrementGridSize();
    print("grid button");
  }
  @override
  bool get debugMode => false;
}