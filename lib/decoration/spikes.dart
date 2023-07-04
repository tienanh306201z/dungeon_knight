import 'package:bonfire/bonfire.dart';

import '../main.dart';
import '../util/sprite_sheet/game_sprite_sheet.dart';

class Spikes extends GameDecoration with Sensor {
  final double damage;

  Spikes(Vector2 position, {this.damage = 5})
      : super.withAnimation(
          animation: GameSpriteSheet.spikes(),
          position: position,
          size: Vector2(tileSize / 2, tileSize / 2),
        ) {
    setupSensorArea(
      // align: Vector2(valueByTileSize(2), valueByTileSize(4)),
      // size: Vector2(valueByTileSize(14), valueByTileSize(12)),
      intervalCheck: 100,
    );
  }

  @override
  void onContact(GameComponent component) {
    if (component is Player) {
      if (animation?.currentIndex == (animation?.frames.length ?? 0) - 1 ||
          animation?.currentIndex == (animation?.frames.length ?? 0) - 2) {
        gameRef.player?.receiveDamage(AttackFromEnum.ENEMY, damage, 0);
      }
    }
  }

  @override
  int get priority => LayerPriority.getComponentPriority(1);

  @override
  void onContactExit(GameComponent component) {}
}
