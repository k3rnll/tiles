import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'game.dart';

enum OpenedTileCase {
  allowed,
  mistake,
  right,
}

class Tile extends PositionComponent with HasGameRef<TileGame>, TapCallbacks {
  final int index;
  final double sideWidth;
  late final Sprite openedSprite;
  late final Sprite closedSprite;
  double rightPause = 0;
  double mistakePause = 0;
  bool isOpen = true;
  bool isMistake = false;
  OpenedTileCase openedCase = OpenedTileCase.allowed;

  Tile({required this.index, required this.sideWidth}) {
    openedSprite = getTileSprite(index);
    closedSprite = getTileSprite(0);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size.setValues(sideWidth, sideWidth);
    anchor = Anchor.center;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isOpen && game.matchStack.length < 2) {
      isOpen = true;
      game.matchStack.add(this);
    }
  }

  @override
  void update(double dt) {
    rightPause = rightPause > 0 ? rightPause -= dt : 0;
    mistakePause = mistakePause > 0 ? mistakePause -= dt : 0;
    if (rightPause == 0 && mistakePause == 0) {
      if (!isMistake) {
        openedCase = OpenedTileCase.allowed;
      } else {
        isOpen = false;
        isMistake = false;
        game.matchStack.clear();
      }
    }
    if (mistakePause > 0) {
      openedCase = OpenedTileCase.mistake;
    }
    if (rightPause > 0) {
      openedCase = OpenedTileCase.right;
    }
  }

  @override
  void render(Canvas canvas) {
    if (isOpen) {
      _renderOpen(canvas);
    } else {
      _renderClose(canvas);
    }
  }

  void _renderOpen(Canvas canvas) {
    Color caseColor = const Color(0xFFFFF8D9);
    if (openedCase == OpenedTileCase.mistake) {
      caseColor = const Color(0xFFFF8D46);
    }
    if (openedCase == OpenedTileCase.right) {
      caseColor = const Color(0xff49da01);
    }
    Paint paint = Paint()..color = caseColor;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Vector2(sideWidth, sideWidth).toRect(), const Radius.circular(20)),
        paint);
    openedSprite.render(canvas);
  }

  void _renderClose(Canvas canvas) {
    Paint paint = Paint()..color = Color(0xFFFFF8D9);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Vector2(sideWidth, sideWidth).toRect(), const Radius.circular(20)),
        paint);
    closedSprite.render(canvas);
  }

  @override
  bool get debugMode => false;
}
