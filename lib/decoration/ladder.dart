import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../player/knight.dart';
import '../util/localization/strings_location.dart';
import '../util/sprite_sheet/game_sprite_sheet.dart';

class Ladder extends GameDecoration with ObjectCollision {
  bool showDialog = false;
  bool canGo;
  Function onDone;

  Ladder(Vector2 position, Vector2 size, this.canGo, this.onDone)
      : super(
          position: position,
          size: Vector2(tileSize, tileSize),
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(width, height / 4),
            align: Vector2(0, height * 0.75),
          ),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.player != null) {
      seeComponent(
        gameRef.player!,
        observed: (player) {
          if (!showDialog) {
            showDialog = true;
            onDone.call();
          }
        },
        notObserved: () {
          showDialog = false;
        },
        radiusVision: (tileSize),
      );
    }
  }

  static void showLadderTalk(BuildContext context) {
    TalkDialog.show(
      context,
      [
        Say(
          text: [
            TextSpan(
              text: getString('can_not_go'),
            )
          ],
          personSayDirection: PersonSayDirection.LEFT,
        )
      ],
    );
  }
}
