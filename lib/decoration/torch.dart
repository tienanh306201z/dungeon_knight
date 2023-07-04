import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../util/sprite_sheet/game_sprite_sheet.dart';

class Torch extends GameDecoration with Lighting {
  bool empty = false;

  Torch(Vector2 position, {this.empty = false})
      : super.withAnimation(
          animation: GameSpriteSheet.torch(),
          position: position,
          size: Vector2(tileSize / 2, tileSize / 2),
        ) {
    setupLighting(
      LightingConfig(
        radius: width * 2.5,
        blurBorder: width,
        pulseVariation: 0.1,
        color: Colors.deepOrangeAccent.withOpacity(0.2),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    if (!empty) {
      super.render(canvas);
    }
  }
}
