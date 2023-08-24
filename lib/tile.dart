import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:tiles/game.dart';

enum OpenedTileCase {
  allowed,
  mistake,
  right,
}

class Tile extends PositionComponent with TapCallbacks {
  int index;
  bool isOpen = true;
  // bool isMistake = false;
  OpenedTileCase openedCase = OpenedTileCase.allowed;
  double sideWidth;
  late Sprite openedSprite;
  late Sprite closedSprite;
  late List<Tile> stack;

  Tile({required this.index, required this.sideWidth, required this.stack}) {
    openedSprite = tileSprite(index);
    closedSprite = tileSprite(0);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size.setValues(sideWidth, sideWidth);
    anchor = Anchor.center;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isOpen && stack.length < 2) {
      isOpen = true;
      stack.add(this);
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
