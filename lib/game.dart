import 'dart:async';
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:tiles/hud.dart';

import 'tile.dart';

class TileGame extends FlameGame {
  static final Random random = Random();
  static const int imgVariants = 19;
  static const double tileWidth = 300.0;
  static const double tilesGap = 16.0;

  int tilesOnLongSide = 12;
  int tilesOnX = 0;
  int tilesOnY = 0;
  int tilesTotal = 0;

  double gridTotalWidth = 0.0;
  double gridTotalHeight = 0.0;
  List<Tile> tiles = List.empty(growable: true);
  List<Tile> stack = List.empty(growable: true);
  double timeToRememberSeconds = 5;
  bool isGameRunning = false;
  double wrongOpenTimeSeconds = 0;
  bool isMistake = false;
  double rightCasePauseSeconds = 0;
  bool isRight = false;

  World world = World();
  CameraComponent cam = CameraComponent();

  void incrementGridSize() {
    int max = tilesOnLongSide + 1;
    double w = size.x;
    double h = size.y - 100;
    if (h > w) {
      max = h / max < 40 ? max - 1 : max;
    } else {
      max = w / max < 40 ? max - 1 : max;
    }
    tilesOnLongSide = max;
    //tilesOnLongSide = tilesOnLongSide > 40 ? 40 : tilesOnLongSide;
  }
  void decrementGridSize() {
    tilesOnLongSide--;
    tilesOnLongSide = tilesOnLongSide < 4 ? 4 : tilesOnLongSide;
    print("${tilesOnLongSide}");
  }

  int getNewGridSize() {
    double w = size.x;
    double h = size.y - 100;
    double scale = w > h ? (w / h) : (h / w);
    int x = w > h ? tilesOnLongSide : (tilesOnLongSide / scale) ~/ 1;
    int y = w > h ? (tilesOnLongSide / scale) ~/ 1 : tilesOnLongSide;
    return x * y;
  }

  void startNewGame() {
    timeToRememberSeconds = 5;
    isGameRunning = false;
    wrongOpenTimeSeconds = 0;
    isMistake = false;
    rightCasePauseSeconds = 0;
    isRight = false;
    world.removeAll(tiles);
    initTilesCounter();
    initNewTiles();
    setTilesPositions();
    world.addAll(tiles);
    gridTotalWidth = tileWidth * tilesOnX + (tilesOnX + 2) * tilesGap;
    gridTotalHeight = tileWidth * tilesOnY + (tilesOnY + 2) * tilesGap;
    cam.viewfinder.visibleGameSize = Vector2(gridTotalWidth, gridTotalHeight);
    cam.viewfinder.position = Vector2(gridTotalWidth / 2, gridTotalHeight / 2);
    cam.viewfinder.anchor = Anchor.center;
  }

  void initTilesCounter() {
    double w = size.x;
    double h = size.y - 100;
    double scale = w > h ? (w / h) : (h / w);
    tilesOnX = w > h ? tilesOnLongSide : (tilesOnLongSide / scale) ~/ 1;
    tilesOnY = w > h ? (tilesOnLongSide / scale) ~/ 1 : tilesOnLongSide;
    tilesTotal = tilesOnX * tilesOnY;
  }

  void initCamera() {
    gridTotalWidth = tileWidth * tilesOnX + (tilesOnX + 2) * tilesGap;
    gridTotalHeight = tileWidth * tilesOnY + (tilesOnY + 2) * tilesGap;
    List<Component> hudComp = List.filled(1, Hud());

    var port = FixedSizeViewport(size.x, size.y - 100)
      ..position = (Vector2(0, 50))

    ;
    cam = CameraComponent(world: world, hudComponents: hudComp, viewport: port)
      ..viewfinder.visibleGameSize = Vector2(gridTotalWidth, gridTotalHeight)
      ..viewfinder.position =
      Vector2(gridTotalWidth / 2,
          gridTotalHeight / 2)
      ..viewfinder.anchor = Anchor.center
    ;
  }

  void setTilesPositions() {
    for (int i = 0; i < tiles.length; i++) {
      tiles[i].position = Vector2(
          (i % tilesOnX) * (tileWidth + tilesGap) + tileWidth / 2 + tilesGap,
          (i ~/ tilesOnX) * (tileWidth + tilesGap) + tileWidth / 2 + tilesGap);
    }
  }

  void closeAllTiles() {
    for (Tile tile in tiles) {
      tile.isOpen = false;
    }
  }

  void initNewTiles() {
    tiles.clear();
    for (int i = 0; i < tilesTotal; i++) {
      int randomInt = random.nextInt(imgVariants) + 1; //0 is question sprite
      if (i >= tilesTotal ~/ 2) {
        randomInt = tiles[i - tilesTotal ~/ 2].index;
      }
      tiles.add(Tile(index: randomInt, sideWidth: tileWidth, stack: stack));
    }
    mixTiles();
  }

  void mixTiles() {
    for (int i = 0; i < tiles.length; i++) {
      int from = random.nextInt(tiles.length);
      int to = random.nextInt(tiles.length);
      Tile tmp = tiles[from];
      tiles[from] = tiles[to];
      tiles[to] = tmp;
    }
  }

  int openedTiles() {
    int opened = 0;
    for (Tile tile in tiles) {
      if (tile.isOpen) {
        opened++;
      }
    }
    return opened;
  }

  @override
  FutureOr<void> onLoad() async {
    Flame.device.setPortraitUpOnly();
    await Flame.images.load('tiles.png');
    startNewGame();
    add(world);
    initCamera();
    await add(cam);
    return super.onLoad();
  }

  void manageLearningPause(double dt) {
    timeToRememberSeconds =
    timeToRememberSeconds > 0 ? timeToRememberSeconds -= dt : 0;
    if (timeToRememberSeconds == 0) {
      isGameRunning = true;
      closeAllTiles();
    }
  }

  void checkMatch() {
    if (stack.length > 1 && !isMistake) {
      if (stack.first.index != stack.last.index) {
        wrongOpenTimeSeconds = 1;
        isMistake = true;
        stack.first.openedCase = OpenedTileCase.mistake;
        stack.last.openedCase = OpenedTileCase.mistake;
      } else {
        rightCasePauseSeconds = 1;
        isRight = true;
        stack.first.openedCase = OpenedTileCase.right;
        stack.last.openedCase = OpenedTileCase.right;
        stack.clear();
      }
    }
  }

  void manageCasePause(double dt) {
    wrongOpenTimeSeconds =
    wrongOpenTimeSeconds > 0 ? wrongOpenTimeSeconds -= dt : 0;
    rightCasePauseSeconds =
    rightCasePauseSeconds > 0 ? rightCasePauseSeconds -= dt : 0;
    if (isRight && rightCasePauseSeconds == 0) {
      isRight = false;
      for (Tile tile in tiles) {
        if (tile.openedCase != OpenedTileCase.mistake) {
          tile.openedCase = OpenedTileCase.allowed;
        }
      }
    }


    if (isMistake && wrongOpenTimeSeconds == 0) {
      isMistake = false;
      stack.first.isOpen = false;
      stack.first.openedCase = OpenedTileCase.allowed;
      stack.last.isOpen = false;
      stack.last.openedCase = OpenedTileCase.allowed;
      stack.clear();
    }
  }

  @override
  void update(double dt) {
    if (!isGameRunning) {
      manageLearningPause(dt);
    } else {
      checkMatch();
      manageCasePause(dt);
    }

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }
}

Sprite tileSprite(int index) {
  int tilesOnX = 4;
  int tilesOnY = 5;
  index = index < tilesOnX * tilesOnY ? index : 0;
  double width = 300;
  double height = 300;
  double x = index % tilesOnX * width;
  double y = index ~/ tilesOnX * height;
  return Sprite(
    Flame.images.fromCache('tiles.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
