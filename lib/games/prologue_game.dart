import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:dungeon_knight/games/level_1_game.dart';
import 'package:dungeon_knight/games/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../decoration/door.dart';
import '../decoration/door_key.dart';
import '../decoration/ladder.dart';
import '../decoration/potion_life.dart';
import '../decoration/spikes.dart';
import '../decoration/torch.dart';
import '../enemies/boss_enemy.dart';
import '../enemies/goblin_enemy.dart';
import '../enemies/imp_enemy.dart';
import '../enemies/miniboss_enemy.dart';
import '../interface/knight_interface.dart';
import '../main.dart';
import '../npc/kid.dart';
import '../npc/wizard_npc.dart';
import '../player/knight.dart';
import '../util/const.dart';
import '../util/dialogs.dart';
import '../util/sounds.dart';

class PrologueGame extends StatefulWidget {
  static bool useJoystick = true;

  const PrologueGame({super.key});

  @override
  State<PrologueGame> createState() => _PrologueGameState();
}

class _PrologueGameState extends State<PrologueGame> implements GameListener {
  bool showGameOver = false;
  late GameController _gameController;
  bool canGo = true;

  @override
  void initState() {
    _gameController = GameController()..addListener(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    Sounds.stopBackgroundSound();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size sizeScreen = MediaQuery.of(context).size;
    tileSize = max(sizeScreen.height, sizeScreen.width) / 15;

    var joystick = Joystick(
      directional: JoystickDirectional(
        spriteBackgroundDirectional:
            Sprite.load('joystick/joystick_background.png'),
        spriteKnobDirectional: Sprite.load('joystick/joystick_knob.png'),
        size: 100,
        isFixed: false,
      ),
      actions: [
        JoystickAction(
          actionId: 0,
          sprite: Sprite.load('joystick/joystick_atack.png'),
          spritePressed: Sprite.load('joystick/joystick_atack_selected.png'),
          size: 80,
          margin: const EdgeInsets.only(bottom: 50, right: 50),
        ),
        JoystickAction(
          actionId: 1,
          sprite: Sprite.load('joystick/joystick_atack_range.png'),
          spritePressed:
              Sprite.load('joystick/joystick_atack_range_selected.png'),
          size: 50,
          margin: const EdgeInsets.only(bottom: 50, right: 160),
        )
      ],
    );

    var objectsBuilder = {
      'torch': (p) => Torch(p.position),
      'wizard': (p) => WizardNpc(p.position),
      'goblin': (p) => GoblinEnemy(p.position),
      'mini_boss': (p) => MiniBoss(p.position),
      'imp': (p) => Imp(p.position),
      'boss': (p) => Boss(p.position),
      'kid': (p) => Kid(p.position),
      'door': (p) => Door(p.position, p.size),
      'spikes': (p) => Spikes(p.position),
      'key': (p) => DoorKey(p.position),
      'ladder': (p) => Ladder(p.position, p.size, canGo, () {
            if (!canGo) {
              Ladder.showLadderTalk(context);
            } else {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const Level1Game()),
              );
            }
          }),
      'potion': (p) => PotionLife(p.position, 30),
    };

    return Material(
      color: Colors.transparent,
      child: BonfireWidget(
        gameController: _gameController,
        joystick: joystick,
        player: Knight(Vector2(2 * tileSize, 2 * tileSize), 'Hiệp sĩ'),
        lightingColorGame: Colors.black.withOpacity(0.6),
        background: BackgroundColorGame(Colors.grey[900]!),
        interface: KnightInterface(),
        onReady: (value) {
          value.player?.receiveDamage(AttackFromEnum.ENEMY, 100, null);
        },
        map: WorldMapByTiled(
          'tiled/prologue_map.json',
          forceTileSize: Vector2(tileSize / 2, tileSize / 2),
          objectsBuilder: objectsBuilder,
        ),
        progress: Container(
          color: Colors.black,
          child: const Center(
            child: Text(
              "Loading...",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Normal',
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void changeCountLiveEnemies(int count) {
    if (count == 0) {
      setState(() {
        canGo = true;
      });
    }
  }

  @override
  void updateGame() {
    if (_gameController.player != null &&
        _gameController.player?.isDead == true) {
      if (!showGameOver) {
        showGameOver = true;
        _showDialogGameOver();
      }
    }
  }

  void _showDialogGameOver() {
    setState(() {
      showGameOver = true;
    });
    Dialogs.showGameOver(
      context,
      () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Menu()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }
}
