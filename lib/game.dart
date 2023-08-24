import 'dart:async';
import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'hud.dart';
import 'tile.dart';
import 'constants.dart';

class TileGame extends FlameGame {
  static final Random random = Random();
  int tilesOnLongSide = initialTilesOnLongSide;
  int tilesOnX = 0;
  int tilesOnY = 0;
  int tilesTotal = 0;
  List<Tile> tiles = List.empty(growable: true);
  List<Tile> matchStack = List.empty(growable: true);
  double timeToRememberSeconds = 0;
  bool isGameRunning = false;
  bool isMistake = false;
  World world = World();
  CameraComponent cam = CameraComponent();

  void startNewGame() {
    timeToRememberSeconds = rememberPauseSeconds;
    isGameRunning = false;
    isMistake = false;
    world.removeAll(tiles);
    matchStack.clear();
    initTilesCounter();
    initNewTiles();
    setTilesPositions();
    world.addAll(tiles);
    setCameraViewfinder();
  }

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
  }

  void decrementGridSize() {
    tilesOnLongSide--;
    tilesOnLongSide = tilesOnLongSide < 4 ? 4 : tilesOnLongSide;
  }

  int calculateNewGridSize() {
    double w = size.x;
    double h = size.y - 100;
    double scale = w > h ? (w / h) : (h / w);
    int x = w > h ? tilesOnLongSide : (tilesOnLongSide / scale) ~/ 1;
    int y = w > h ? (tilesOnLongSide / scale) ~/ 1 : tilesOnLongSide;
    return (x * y) % 2 == 0 ? (x * y) : (x * y) - 1;
  }

  void initTilesCounter() {
    double w = size.x;
    double h = size.y - 100;
    double scale = w > h ? (w / h) : (h / w);
    tilesOnX = w > h ? tilesOnLongSide : (tilesOnLongSide / scale) ~/ 1;
    tilesOnY = w > h ? (tilesOnLongSide / scale) ~/ 1 : tilesOnLongSide;
    tilesTotal = (tilesOnX * tilesOnY) % 2 == 0 ?
      (tilesOnX * tilesOnY) :
      (tilesOnX * tilesOnY) - 1;
  }

  void setCameraViewfinder() {
    double gridTotalWidth = tileSpriteWidth * tilesOnX + (tilesOnX + 2) * tilesGap;
    double gridTotalHeight = tileSpriteWidth * tilesOnY + (tilesOnY + 2) * tilesGap;
    cam.viewfinder.visibleGameSize = Vector2(gridTotalWidth, gridTotalHeight);
    cam.viewfinder.position = Vector2(gridTotalWidth / 2, gridTotalHeight / 2);
    cam.viewfinder.anchor = Anchor.center;
  }

  void initCamera() {
    List<Component> hudComp = List.filled(1, Hud());
    var port = FixedSizeViewport(size.x, size.y - 100)
      ..position = (Vector2(0, 50));
    cam = CameraComponent(world: world, hudComponents: hudComp, viewport: port);
    setCameraViewfinder();
  }

  void setTilesPositions() {
    for (int i = 0; i < tiles.length; i++) {
      tiles[i].position = Vector2(
          (i % tilesOnX) * (tileSpriteWidth + tilesGap) + tileSpriteWidth / 2 + tilesGap,
          (i ~/ tilesOnX) * (tileSpriteWidth + tilesGap) + tileSpriteWidth / 2 + tilesGap);
    }
  }

  void initNewTiles() {
    tiles.clear();
    for (int i = 0; i < tilesTotal; i++) {
      int randomInt = random.nextInt(tileSpritesVariants) + 1; //0 is question sprite
      if (i >= tilesTotal ~/ 2) {
        randomInt = tiles[i - tilesTotal ~/ 2].index;
      }
      tiles.add(Tile(index: randomInt, sideWidth: tileSpriteWidth));
    }
    if (tiles.length % 2 != 0) {
      tiles.removeLast();
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

  void manageLearningPause(double dt) {
    timeToRememberSeconds =
    timeToRememberSeconds > 0 ? timeToRememberSeconds -= dt : 0;
    if (timeToRememberSeconds == 0) {
      isGameRunning = true;
      for (Tile tile in tiles) {
        tile.isOpen = false;
      }
    }
  }

  void checkMatch() {
    if (matchStack.length < 2) {
      isMistake = false;
    }
    if (matchStack.length > 1 && !isMistake) {
      isMistake = matchStack.first.index != matchStack.last.index;
      if (isMistake) {
        matchStack.first.mistakePause = wrongMatchPauseSeconds;
        matchStack.last.mistakePause = wrongMatchPauseSeconds;
        matchStack.first.isMistake = true;
        matchStack.last.isMistake = true;
      } else {
        matchStack.first.rightPause = rightMatchPauseSeconds;
        matchStack.last.rightPause = rightMatchPauseSeconds;
        matchStack.clear();
      }
    }
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

  @override
  void update(double dt) {
    if (!isGameRunning) {
      manageLearningPause(dt);
    } else {
      checkMatch();
    }
    super.update(dt);
  }
}

Sprite getTileSprite(int index) {
  int tilesOnX = 4;
  int tilesOnY = 5;
  index = index < tilesOnX * tilesOnY ? index : 0;
  double width = tileSpriteWidth;
  double height = tileSpriteWidth;
  double x = index % tilesOnX * width;
  double y = index ~/ tilesOnX * height;
  return Sprite(
    Flame.images.fromCache('tiles.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
