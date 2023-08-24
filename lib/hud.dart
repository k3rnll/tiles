import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'game.dart';

class Hud extends PositionComponent with HasGameRef<TileGame> {

  @override
  Future<void>? onLoad() async {
    super.size = Vector2((game.size.x - 1), 50);
    super.position = (Vector2(0, game.cam.viewport.size.y));
    super.anchor = Anchor.topLeft;
    add(RestartButton());
    add(PauseCountDown());
    add(GridSizeButtonMinus());
    add(GridSize());
    add(GridSizeButtonPlus());
    return super.onLoad();
  }

  @override
  bool get debugMode => false;
}

class PauseCountDown extends TextComponent with HasGameRef<TileGame> {
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
    super.text = "${game.calculateNewGridSize()}";
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
  // @override
  // void render(Canvas canvas) {
  //   super.render(canvas);
  // }

  @override
  void onTapDown(TapDownEvent event) {
    game.decrementGridSize();
  }

  @override
  bool get debugMode => false;
}